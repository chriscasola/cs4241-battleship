=begin
  This file contains the RegisterApi class.
  
  @author Chris Page
  @version 4/14/2012
=end

require 'sinatra/base'
require 'tools/hashPassword'
require 'tools/inputValidator'
require 'tools/dbTools'

# This class handles the server side registration stuff
class RegisterApi < Sinatra::Base

	# SQL statement for selecting an email from the users table given an email
    @@SQL_SelectEmailFromUsers =
<<EOS
SELECT email FROM users
WHERE email='%%email%%';
EOS

	# SQL statement for selecting a name from the users table given a name
    @@SQL_SelectNameFromUsers =
<<EOS
SELECT name FROM users
WHERE name='%%name%%';
EOS

	# SQL statement for inserting a new record into the users table
    @@SQL_InsertUserRecord =
<<EOS
INSERT INTO users VALUES (default, '%%name%%', '%%email%%', '%%password%%');
EOS

	# JSON returned if registration was successful
	@@JSON_Success = {'success' => true}
	
	# JSON returned if registration was unsuccessful
	@@JSON_Failure = {'success' => false, 'error' => ''}
    
    # Path for register api post
    post '/api/register' do
  		register(params[:email], params[:password1], params[:password2], params[:name])
	end
	
	# Attempts to register a new user with the given information.
    # TODO This function needs to also insert a record into the users_icons table.
    # @param [String] email The user's email address.
    # @param [String] password1  The user's password.
    # @param [String] password2  The user's password (confirmation).
    # @param [String] name	The user's name.
    def register (email, password1, password2, name)
        # If the email, password, and name are valid
        if (validateEmail(email) && validatePassword(password1) && validatePassword(password2) && validateName(name))

            # If the passwords match
            if (password1 == password2)
                conn = DBTools.new.connectToDB()

                # Check if email is already in the database
                query = @@SQL_SelectEmailFromUsers.gsub(/%%email%%/, conn.escape_string(email))
                results = conn.exec(query)

                # If the email is not already in the database
                if (results.ntuples == 0)
                    results.clear()

                    # Check if name is already in the database
                    query = @@SQL_SelectNameFromUsers.gsub(/%%name%%/, conn.escape_string(name))
                    results = conn.exec(query)

                    # If the name is not already in the database
                    if (results.ntuples == 0)
                        # Insert user record
                        query = @@SQL_InsertUserRecord.gsub(/%%name%%/, conn.escape_string(name)).gsub(/%%email%%/, conn.escape_string(email)).gsub(/%%password%%/, hashPassword(password1))
                        
                        results = conn.exec(query)

                        # Record successfully inserted
                        if (results.cmd_tuples() == 1)
                            # return JSON
                            json_output = @@JSON_Success
                            json_output['success'] = true
                            conn.finish()

                            JSON.generate(json_output)

                        # Record insertion unsuccessful
                        else
                            json_output = @@JSON_Failure
                            json_output['success'] = false
                            json_output['error'] = "User record creation failed."
                            conn.finish()

                            JSON.generate(json_output)
                        end

                    # If the name is already in the database
                    else
                        json_output = @@JSON_Failure
                        json_output['success'] = false
                        json_output['error'] = "Name already in use."
                        results.clear()
                        conn.finish()

                        JSON.generate(json_output)
                    end

                # If the email is already in the database
                else
                    json_output = @@JSON_Failure
                    json_output['success'] = false
                    json_output['error'] = "Email address already in use."
                    results.clear()
                    conn.finish()

                    JSON.generate(json_output)
                end

            # If the passwords do not match
            else
                json_output = @@JSON_Failure
                json_output['success'] = false
                json_output['error'] = "Passwords do not match."
                JSON.generate(json_output)
            end

        # If the email, password or name is invalid.
        else
            json_output = @@JSON_Failure
            json_output['success'] = false
            json_output['error'] = "Email, password or name is invalid."
            JSON.generate(json_output)
        end
    end
end
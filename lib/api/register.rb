=begin
  This file contains the register api function.
  
  @author Chris Page
  @version 4/14/2012
=end

require 'sinatra/base'
require 'tools/hashPassword'
require 'tools/inputValidator'
require 'api/dbmgr'

class RegisterApi < Sinatra::Base

    @@SQL_SelectEmailFromUsers =
<<EOS
SELECT email FROM users
WHERE email='%%email%%';
EOS

    @@SQL_SelectNameFromUsers =
<<EOS
SELECT name FROM users
WHERE name='%%name%%';
EOS

    @@SQL_InsertUserRecord =
<<EOS
INSERT INTO users (name, email, password)
VALUES ('%%name%%', %%email%%, %%password%%);
EOS

	@@JSON_Success = {'success' => true}
	@@JSON_Failure = {'success' => false, 'error' => ''}
    
    post '/api/register' do
  		register(params[:email], params[:password1], params[:password2], params[:name])
	end

    def register (email, password1, password2, name)
        # If the email, password, and name are valid
        if (validateEmail(email) && validatePassword(password1) && validatePassword(password2) && validateName(name))

            # If the passwords match
            if (password1 == password2)
                conn = connectToDB(ENV['SHARED_DATABASE_URL'])

                # Check if email is already in the database
                query = @@SQL_SelectEmailFromUsers.gsub(/%%email%%/, email)
                results = conn.exec(query)

                # If the email is not already in the database
                if (results.ntuples == 0)
                    results.clear()

                    # Check if name is already in the database
                    query = @@SQL_SelectNameFromUsers.gsub(/%%name%%/, name)
                    results = conn.exec(query)

                    # If the name is not already in the database
                    if (results.ntuples == 0)
                        # Insert user record
                        query = @@SQL_InsertUserRecord.gsub(/%%name%%/, name).gsub(/%%email%%/, email).gsub(/%%password%%/, hashPassword(password))
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
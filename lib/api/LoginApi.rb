=begin
  This file contains the LoginApi class.
  
  @author Chris Page
  @version 4/14/2012
=end

require 'sinatra/base'
require 'digest/sha2'
require 'json'
require 'tools/hashPassword'
require 'tools/inputValidator'
require 'tools/dbTools'

# This class handles the server-side login stuff.
class LoginApi < Sinatra::Base
	
	# Enable sessions
	enable :sessions
	
	# SQL statement for selecting a user id given an email and a hashed password
    @@SQL_SelectUserIdViaCredentials =
<<EOS
SELECT userid, name FROM users
WHERE email='%%email%%'
AND password='%%password%%';
EOS
	
	# SQL statement for inserting a new record into the user's online table
    @@SQL_InsertNewOnlineRecord =
<<EOS
INSERT INTO users_online (sessionid, userid)
VALUES ('%%sessionid%%', %%userid%%);
EOS
	
	# JSON returned if login was successful
    @@JSON_LoginSuccessful = {'success' => true, 'name' => '', 'userid' => -1, 'sessionid' => -1}
    
    # JSON returned if login was unsuccessful
    @@JSON_LoginFailed = {'success' => false, 'error' => ''}
    
    # Path for login api post
    post '/api/login' do
  		login(params[:email], params[:password])
	end

    # Generates a unique session id.
    #
    # @param [Integer] userid The userid.
    #
    # @return [String] A unique session id.
    def generateUniqueSessionId(userId)
        toHash = Time.now.to_s + userId.to_s

        sha256 = Digest::SHA256.new
        hashedUSId = sha256.hexdigest(toHash)
        return hashedUSId
    end

    # Attempts to log in a user with the given information.
    #
    # @param [String] email The user's email address.
    # @param [String] password  The user's password.
    def login(email, password)

        # If the email and password are valid
        if (validateEmail(email) && validatePassword(password))
            conn = DBTools.new.connectToDB()

            # Get userid based on credentials. There will be no results if the credentials are wrong.
            # TODO Escape the email.

            query = @@SQL_SelectUserIdViaCredentials.gsub(/%%email%%/, email).gsub(/%%password%%/, hashPassword(password))
            results = conn.exec(query)

            # If the credentials are wrong (0 results)
            if (results.ntuples == 0)
            	json_output = @@JSON_LoginFailed
                json_output['success'] = false
                json_output['error'] = "Email or password not found."
                conn.finish()
                JSON.generate(json_output)

            # If there are too many results (this should never occur)
            elsif (results.ntuples > 1)
            	json_output = @@JSON_LoginFailed
                json_output['success'] = false
                json_output['error'] = "Database is corrupt."
                conn.finish()
                JSON.generate(json_output)

            # If the credentials are valid
            else
                userid = results[0]['userid']
                name = results[0]['name']
                results.clear()
                sessionid = generateUniqueSessionId(userid)

                query = @@SQL_InsertNewOnlineRecord.gsub(/%%sessionid%%/, sessionid).gsub(/%%userid%%/, userid)
                results = conn.exec(query)

                if (results.cmd_tuples() == 1)
                    # generate session cookie
                    session["sessionid"] = sessionid

                    # return JSON
            		json_output = @@JSON_LoginSuccessful
                    json_output['success'] = true
                    json_output['name'] = name
                    json_output['userid'] = userid
                    json_output['sessionid'] = sessionid
                    conn.finish()

                    JSON.generate(json_output)
                else
            		json_output = @@JSON_LoginFailed
                    json_output['success'] = false
                    json_output['error'] = "Session not inserted."
                    conn.finish()

                    JSON.generate(json_output)
                end
            end

        # If the email or password is invalid.
        else
            json_output = @@JSON_LoginFailed
            json_output['success'] = false
            json_output['error'] = "Email or password is invalid."
            JSON.generate(json_output)
        end
    end
end
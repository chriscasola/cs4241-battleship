=begin
  This file contains the LoginApi class.
  
  @author Chris Page
  @version 4/25/2012
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
    #
    # @return	The JSON response to send to the client.
    def login(email, password)

        # If the email and password are valid
        if (validateEmail(email) && validatePassword(password))
        	begin
        		# Get userid, name based on credentials.
        		returnHash = selectUseridAndNameViaCredentials(email, password)
        		userid = returnHash[:userid]
        		name = returnHash[:name]
        		
        		# Generate a unique sessionid based on the userid
        		sessionid = generateUniqueSessionId(userid)
        		
        		# Insert a new record into users_online
        		insertNewUsersOnlineRecord(sessionid, userid)
        		
        		# generate session cookie
                session["sessionid"] = sessionid

                # return JSON
                return generateJSON_Login(true, {:name => name, :userid => userid, :sessionid => sessionid})
        	
        	# If an exception is thrown
        	rescue Exception => ex
        		return generateJSON_Login(false, {:error => ex.message})
        	end

        # If the email or password is invalid.
        else
        	return generateJSON_Login(false, {:error => "Email or password is invalid."})
        end
    end
    
    # Generates the JSON to send to the client in response to a login request
    # TODO Perhaps check to make sure hash values are correct types.
    #
    # @param [boolean]	success	Whether or not the client has successfully 
    # => 						logged in
    # @param [Hash]		hash	If success is true, it should map :name to the 
    # => 						user's name, :userid to the user's userid, and 
    # => 						:sessionid to the user's sessionid. If success 
    # => 						if false, it should map :error to a String 
    # => 						describing why login was unsuccessful.
    #
    # @return	The JSON response to send to the client.
    def generateJSON_Login(success, hash)
    	if (success)
    		return JSON.generate({'success' => true, 'name' => hash[:name], 'userid' => hash[:userid], 'sessionid' => hash[:sessionid]})
    	else
    		return JSON.generate({'success' => false, 'error' => hash[:error]})
    	end
    end
    
    # Inserts a new record into users_online table
    #
    # @param [String]	sessionid	The sessionid
    # @param [Integer]	userid		The userid
    #
    # @raise	If there isn't exactly one updated row.
    def insertNewUsersOnlineRecord(sessionid, userid)
    	
    	# SQL statement for inserting a new record into the users_online table
    	query = "INSERT INTO users_online (sessionid, userid)
				VALUES ('%%sessionid%%', %%userid%%);"
		
		# Fill in sessionid and userid values in the SQL statement
    	query = query.gsub(/%%sessionid%%/, sessionid).gsub(/%%userid%%/, userid)
    	
    	# Connect to the database
		conn = DBTools.new.connectToDB()
    	
    	# Execute SQL statement
        results = conn.exec(query)
        
        # If there isn't exactly one updated row, raise exception
        if (results.cmd_tuples() != 1)
			results.clear()
			conn.finish()
			raise "Session not inserted."
		end
   	end
    
    # Gets a userid and name via the given credentials
    #
    # @param [String] email		The user's email address.
    # @param [String] password	The user's password.
    #
    # @raise	If there is no user or too many users with the given 
    # => 		credentials.
    # @return	A hash with the :userid and :name of the user with the given 
    # => 		credentials.
    def selectUseridAndNameViaCredentials(email, password)
    	
    	# SQL statement for selecting a user id given an email and a hashed password
    	query = "SELECT userid, name FROM users
				WHERE email='%%email%%'
				AND password='%%password%%';"
		
		# Fill in email and password values in the SQL statement
    	query = query.gsub(/%%email%%/, PG::Connection.escape_string(email)).gsub(/%%password%%/, hashPassword(password))
    	
    	# Connect to the database
    	conn = DBTools.new.connectToDB()
    	
    	# Execute SQL Statement
        results = conn.exec(query)
        
        # If the credentials not found (0 results)
        if (results.ntuples == 0)
        	results.clear()
            conn.finish()
            raise "Email or password not found."

        # If there are too many results (this should never occur)
        elsif (results.ntuples > 1)
        	results.clear()
        	conn.finish()
            raise "Too many results given credentials."
        
        # Query successful
        else
        	returnHash = {:userid => results[0]['userid'], :name => results[0]['name']}
        	results.clear()
        	conn.finish()
        	return returnHash
        end
    end
end
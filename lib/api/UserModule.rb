=begin
  TODO This comment
  
  @author Chris Page
  @version 4/25/2012
=end

require 'sinatra/base'
require 'json'
require 'tools/inputValidator'
require 'tools/dbTools'

# This class handles dealing with users server-side. It is intended to 
# eventually replace LoginApi and RegisterApi.
class UserModule < Sinatra::Base
	
	# Enable sessions
	enable :sessions

	
	get '/user/basicinfo' do
		basicInfo(params[:userid])
	end
	
	# Handle path for get request to find out who user is
	#post '/user/whoami' do
	#	whoami()
	#end
	
	# Handle path for post request to login user
    #post '/user/login' do
  	#	login(params[:email], params[:password])
	#end
	
	# Handle path for post request to logout user
	#post '/user/logout' do
	#	logout()
	#end
	
	# Handle path for post request to register new user
    #post '/user/register' do
  	#	register(params[:email], params[:password1], params[:password2], params[:name])
	#end
	
	# Handle path for post request to update user information
	post '/user/update' do
		update(params[:cPassword], params[:nPassword1], params[:nPassword2], params[:nEmail1], params[:nEmail2], params[:nName], params[:nIconId])
	end
	get '/user/update' do
		update(params[:cPassword], params[:nPassword1], params[:nPassword2], params[:nEmail1], params[:nEmail2], params[:nName], params[:nIconId])
	end
	
	
	# TODO This comment
	def basicInfo (userid)
		name = nil
		iconid = nil
		nameError = nil
		iconidError = nil
		
		begin
			name = db_select_user_name(userid)
		rescue Exception => ex
			nameError = ex.message
		end
		
		begin
			iconid = db_select_usersicons_iconid(userid)
		rescue Exception => ex
			iconidError = ex.message
		end
		
		return generateJSON_BasicInfo(name, nameError, iconid, iconidError)
	end
	
	
	
	
	
	
	
	
	# Updates a user's information. This will only update information from 
	# parameters that are non-blank.
	#
	# @param [String]	cPassword	The user's current password.
	# @param [String]	nPassword1	A new password.
	# @param [String]	nPassword2	A new password (confirmation).
	# @param [String]	nEmail1		A new email.
	# @param [String]   nEmail2		A new email (confirmation).
	# @param [String]	nName		A new name.
	# @param [String]	nIconid		A new icon id.
	#
	# @return	The JSON response to send to the client.
	def update(cPassword, nPassword1, nPassword2, nEmail1, nEmail2, nName, nIconid)
		
		# Get the sessionid from the session
		sessionid = session['sessionid']
		
		begin
			# Get the userid given the sessionid
			userid = db_select_user_userid(sessionid)
		
			# If the password is valid and the password is correct
        	if (validatePassword(cPassword) && db_verify_user_password(userid, cPassword))
        		
        		# Change password
        		if (nPassword1 != "")
        			if (validatePassword(nPassword1) && nPassword1 == nPassword2)
        				db_update_user_password(userid, nPassword1)
        			end
        		end
        		
        		# Change email
        		if (nEmail1 != "")
        			if (validateEmail(nEmail1) && nEmail1 == nEmail2)
        				db_update_user_email(userid, nEmail1)
        			end
        		end
        		
        		# Change name
        		if (nName != "")
        			if (validateName(nName))
        				db_update_user_name(userid, nName)
        			end
        		end
        		
        		# Change picture
        		if (nIconid != "")
        			db_update_user_icon(userid, nIconid)
        		end
        		
        		return generateJSON_Update(true, '')
        		
        	# If password is invalid
        	else
        		return generateJSON_Update(false, {:error => "Invalid password. " + cPassword + "|" + nPassword1})
        	end
        	
        # If an exception is thrown
		rescue Exception => ex
        	return generateJSON_Update(false, {:error => ex.message})
		end
	end
	
	# Gets the name from the users table using the userid.
	#
	# @param	userid	The userid
	#
	# @raise	If there is no userid.
	# @return	The name of the user with the given userid.
	def db_select_user_name(userid)
		
		# SQL statement for selecting a userid given a sessionid
		query = "SELECT name FROM users 
				WHERE userid='%%userid%%';"
		
		# Fill in userid value in the SQL statement
		query = query.gsub(/%%userid%%/, PG::Connection.escape_string(userid))
		
		# Connect to the database
    	conn = DBTools.new.connectToDB()
    	
    	# Execute SQL Statement
        results = conn.exec(query)
		
		# If the userid is not found (0 results)
        if (results.ntuples == 0)
        	results.clear()
            conn.finish()
            raise "Invalid sessionid."
        
        # Query successful
        else
        	userid = results[0]['name']
        	results.clear()
        	conn.finish()
        	return userid
        end
	end
	
	# Gets the userid from the online_users table using the sessionid.
	#
	# @param [String]	sessionid	The sessionid
	#
	# @raise	If there is no session id or too many sessionids in the 
	# => 		database.
	# @return	The userid of the user logged in with the given sessionid.
	def db_select_user_userid(sessionid)
		
		# SQL statement for selecting a userid given a sessionid
		query = "SELECT userid FROM users_online 
				WHERE sessionid='%%sessionid%%';"
		
		# Fill in sessionid value in the SQL statement
		query = query.gsub(/%%sessionid%%/, PG::Connection.escape_string(sessionid))
		
		# Connect to the database
    	conn = DBTools.new.connectToDB()
    	
    	# Execute SQL Statement
        results = conn.exec(query)
		
		# If the sessionid is not found (0 results)
        if (results.ntuples == 0)
        	results.clear()
            conn.finish()
            raise "Invalid sessionid."

        # If there are too many results (this should never occur)
        elsif (results.ntuples > 1)
        	results.clear()
        	conn.finish()
            raise "Too many sessionids."
        
        # Query successful
        else
        	userid = results[0]['userid']
        	results.clear()
        	conn.finish()
        	return userid
        end
	end
	
	# Gets an iconid from the users_icons table using the userid.
	#
	# @param	userid	The userid
	#
	# @raise	If there is no record associated with the given userid.
	# @return	The iconid of the user with the given userid.
	def db_select_usersicons_iconid(userid)
		
		# SQL statement for selecting a userid given a sessionid
		query = "SELECT icon FROM users_icons 
				WHERE userid='%%userid%%';"
		
		# Fill in userid value in the SQL statement
		query = query.gsub(/%%userid%%/, PG::Connection.escape_string(userid))
		
		# Connect to the database
    	conn = DBTools.new.connectToDB()
    	
    	# Execute SQL Statement
        results = conn.exec(query)
		
		# If the userid is not found (0 results)
        if (results.ntuples == 0)
        	results.clear()
            conn.finish()
            raise "Invalid sessionid."
        
        # Query successful
        else
        	userid = results[0]['icon']
        	results.clear()
        	conn.finish()
        	return userid
        end
	end
	
	# Updates a user's email
	#
	# @param	userid	The userid of the user to update
	# @param	email	The new email
	#
	# @raise If there are no records or too many records updated.
	def db_update_user_email(userid, email)
		
		# SQL statement for updating a user's email
		query = "UPDATE users
				SET email='%%email%%'
				WHERE userid='%%userid%%';"
		
		# Fill in the email and userid values in the SQL statement
		query = query.gsub(/%%email%%/, PG::Connection.escape_string(email)).gsub(/%%userid%%/, PG::Connection.escape_string(userid))
		
		# Connect to the database
		conn = DBTools.new.connectToDB()
		
		#Execute SQL Statement
		results = conn.exec(query)
		
		# If there are 0 results
        if (results.cmd_tuples() == 0)
        	results.clear()
            conn.finish()
            raise "Email not updated."

        # If there are too many results (this should never occur)
        elsif (results.cmd_tuples() > 1)
        	results.clear()
        	conn.finish()
            raise "Too many emails changed. Database now corrupt."
        
        # Update successful
        else
        	results.clear()
        	conn.finish()
        end
	end
	
	# Update a user's icon
	#
	# @param	userid	The id of the user to update.
	# @param	iconid	The new iconid.
	#
	# @raise	If no icons are updated or too many icons are updated.
	def db_update_user_icon(userid, iconid)
		
		# SQL statement for updating a user's email
		query = "UPDATE users_icons
				SET icon='%%icon%%'
				WHERE userid='%%userid%%';"
		
		# Fill in the icon and userid values in the SQL statement
		query = query.gsub(/%%icon%%/, PG::Connection.escape_string(iconid)).gsub(/%%userid%%/, PG::Connection.escape_string(userid))
		
		# Connect to the database
		conn = DBTools.new.connectToDB()
		
		#Execute SQL Statement
		results = conn.exec(query)
		
		# If there are 0 results
        if (results.cmd_tuples() == 0)
        	results.clear()
            conn.finish()
            raise "Icon not updated."

        # If there are too many results (this should never occur)
        elsif (results.cmd_tuples() > 1)
        	results.clear()
        	conn.finish()
            raise "Too many icons changed. Database now corrupt."
        
        # Update successful
        else
        	results.clear()
        	conn.finish()
        end
	end
	
	
	
	# Updates a user's name
	#
	# @param	userid	The userid of the user to update.
	# @param	name	The new name.
	#
	# @raise	If there are 0 or too many rows updated.
	def db_update_user_name(userid, name)
		
		# SQL statement for updating a user's name
		query = "UPDATE users
				SET name='%%name%%'
				WHERE userid='%%userid%%';"
		
		# Fill in the name and userid values in the SQL statement
		query = query.gsub(/%%name%%/, PG::Connection.escape_string(name)).gsub(/%%userid%%/, PG::Connection.escape_string(userid))
		
		# Connect to the database
		conn = DBTools.new.connectToDB()
		
		#Execute SQL Statement
		results = conn.exec(query)
		
		# If there are 0 results
        if (results.cmd_tuples() == 0)
        	results.clear()
            conn.finish()
            raise "Name not updated."

        # If there are too many results (this should never occur)
        elsif (results.cmd_tuples() > 1)
        	results.clear()
        	conn.finish()
            raise "Too many names changed. Database now corrupt."
        
        # Update successful
        else
        	results.clear()
        	conn.finish()
        end
	end
	
	
	
	# Updates a user's password.
	#
	# @param	userid The userid of the user to update.
	# @param	password	The new password.
	#
	# @raise	If no rows are updated or too many rows are updated.
	def db_update_user_password(userid, password)
		
		# SQL statement for updating a user's password
		query = "UPDATE users
				SET password='%%password%%'
				WHERE userid='%%userid%%';"
		
		# Fill in the password and userid values in the SQL statement
		query = query.gsub(/%%password%%/, hashPassword(password)).gsub(/%%userid%%/, PG::Connection.escape_string(userid))
		
		# Connect to the database
		conn = DBTools.new.connectToDB()
		
		#Execute SQL Statement
		results = conn.exec(query)
		
		# If there are 0 results
        if (results.cmd_tuples() == 0)
        	results.clear()
            conn.finish()
            raise "Password not updated."

        # If there are too many results (this should never occur)
        elsif (results.cmd_tuples() > 1)
        	results.clear()
        	conn.finish()
            raise "Too many passwords changed. Database now corrupt."
        
        # Update successful
        else
        	results.clear()
        	conn.finish()
        end
	end
	
	# Verifies that the userid and password match.
	#
	# @param	userid		The userid of the record to check.
	# @param	password	The password to verify.
	#
	# @raise	If there are too many password matches.
	# @return [boolean]	True if the userid and password match, false otherwise.
	def db_verify_user_password(userid, password)
		
		# SQL statement for selecting * given a userid and a hashed password
    	query = "SELECT * FROM users
				WHERE userid='%%email%%'
				AND password='%%password%%';"
		
		# Fill in userid and password values in the SQL statement
    	query = query.gsub(/%%email%%/, PG::Connection.escape_string(userid)).gsub(/%%password%%/, hashPassword(password))
    	
    	# Connect to the database
    	conn = DBTools.new.connectToDB()
    	
    	# Execute SQL Statement
        results = conn.exec(query)
        
        # If there are 0 results
        if (results.ntuples == 0)
        	results.clear()
            conn.finish()
            return false

        # If there are too many results (this should never occur)
        elsif (results.ntuples > 1)
        	results.clear()
        	conn.finish()
            raise "Too many password matches."
        
        # Query successful
        else
        	results.clear()
        	conn.finish()
        	return true
        end
	end
	
	# TODO This comment
	def generateJSON_BasicInfo(name, nameError, iconid, iconidError)
    	return JSON.generate({'name' => name, 'nameError' => nameError, 'iconid' => iconid, 'iconidError' => iconidError})
    end
	
	# TODO This comment
	def generateJSON_Update(success, error)
		if (success)
    		return JSON.generate({'success' => success})
    	else
    		return JSON.generate({'success' => success, 'error' => error[:error]})
    	end
    end
end
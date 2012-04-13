=begin
  This file contains the login api function.
  
  @author Chris Page
  @version 4/12/2012
=end

require 'digest/sha2'
require 'dbmgr'
require 'iconv'
require 'json'
require 'tools/hashPassword'
require 'tools/inputValidator'

SQL_SelectUserIdViaCredentials = 
<<EOS
SELECT userid, name FROM users
WHERE email='%%email%%'
AND password='%%password%%';
EOS

SQL_InsertNewOnlineRecord = 
<<EOS
INSERT INTO users_online (sessionid, userid)
VALUES ('%%sessionid%%', %%userid%%);
EOS

JSON_Output = {'success' => false, 'name' => '', 'userid' => -1, 'sessionid' => -1, 'error' => ''}

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
    conn = connectToDB(ENV['SHARED_DATABASE_URL'])
    
    # Get userid based on credentials. There will be no results if the credentials are wrong.
    # TODO Escape the email.
    
    query = SQL_SelectUserIdViaCredentials.gsub(/%%email%%/, email).gsub(/%%password%%/, hashPassword(password))
    #ic = Iconv.new('UNICODE//IGNORE', 'UTF-8')
    #query = ic.iconv(query)
    results = conn.exec(query)
    
    # If the credentials are wrong (0 results)
    if (results.ntuples == 0)
      JSON_Output['success'] = false
      JSON_Output['error'] = "Email or password not found."
      conn.finish()
      JSON.generate(JSON_Output)
      
    # If there are too many results (this should never occur)
    elsif (results.ntuples > 1)
      JSON_Output['success'] = false
      JSON_Output['error'] = "Database is corrupt."
      conn.finish()
      JSON.generate(JSON_Output)
      
    # If the credentials are valid
    else
      userid = results[0]['userid']
      name = results[0]['name']
      results.clear()
      sessionid = generateUniqueSessionId(userid)
      
      query = SQL_InsertNewOnlineRecord.gsub(/%%sessionid%%/, sessionid).gsub(/%%userid%%/, userid)
      results = conn.exec(query)
      
      if (results.cmd_tuples() == 1)
        # generate session cookie
        session["sessionid"] = sessionid
        
        # return JSON
        JSON_Output['success'] = true
        JSON_Output['name'] = name
        JSON_Output['userid'] = userid
        JSON_Output['sessionid'] = sessionid
        conn.finish()
        
        JSON.generate(JSON_Output)
      else
        JSON_Output['success'] = false
        JSON_Output['error'] = "Session not inserted."
        conn.finish()
        
        JSON.generate(JSON_Output)
      end
    end
    
  # If the email or password is invalid.
  else
    JSON_Output['success'] = false
    JSON_Output['error'] = "Email or password is invalid."
    JSON.generate(JSON_Output)
  end
  
  # TODO add library for checking if user is logged in
end

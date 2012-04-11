=begin
  TODO: Complete this comment.
  
  @author Chris Page
  @version 4/4/2012
=end

require 'digest/sha2'
require 'dbmgr'
require 'iconv'

SQL_SelectUserIdViaCredentials = 
<<EOS
SELECT userid, name FROM users
WHERE email='%%email%%'
AND password='%%password%%';
EOS

SQL_InsertNewOnlineRecord = 
<<EOS
INSERT INTO users_online (sessionid, userid)
VALUES (%%sessionid%%, %%userid%%);
EOS

JSON_Error = 
<<EOS
{"login": {
  "loggedin": "false",
  "error": "%%error%%"
}}
EOS

JSON_LoginSuccessful = 
<<EOS
{"login": {
  "loggedin": "true",
  "name": "%%name%%"
}}
EOS

# Checks whether or not the given email is an actual email address.
#
# @param [String] email The email to check.
#
# @return [boolean] True if the email is a valid email. False otherwise.
def validateEmail(email)
  if (email == nil)
    return false
  end
  
  # TODO Until this function is correctly implemented, it causes a horrendous security vulnerability.
  return true # TODO This is wrong. Finished this function.
end

# Checks whether or not the password is valid.
#
# @param [String] password The password to check.
#
# @return [boolean] True if the password is valid. False otherwise.
def validatePassword(password)
  if (password == nil)
    return false
  end
  
  return true # TODO This is wrong. Finish this function.
end

# Hashes a password before checking the database
#
# @param [String] password The password to hash.
#
# @return [String] The hashed password.
def hashPassword(password)
  sha256 = Digest::SHA256.new
  hashedPwd = sha256.hexdigest(password)
  return hashedPwd
end

# Generates a unique session id.
#
# @param [Integer] userid The userid.
#
# @return [String] A unique session id.
def generateUniqueSessionId(userId)
  toHash = Time.now.to_s + userId.to_s
  
  sha256 = Digest::SHA256.new
  hashedUSId = sha256.digest(toHash)
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
    File.open('battle.log', 'w') {|f| f.write(query) }
    #ic = Iconv.new('UNICODE//IGNORE', 'UTF-8')
    #query = ic.iconv(query)
    results = conn.exec(query)
    
    # If the credentials are wrong (0 results)
    if (results.ntuples == 0)
      JSON_Error.gsub(/%%error%%/, "Email or password not found.");
      
    # If there are too many results (this should never occur)
    elsif (results.ntuples > 1)
      JSON_Error.gsub(/%%error%%/, "Database is corrupt.");
      
    # If the credentials are valid
    else
      userid = results[0]['userid']
      name = results[0]['name']
      results.clear()
      sessionid = generateUniqueSessionId(userid)
      results = conn.exec(SQL_InsertNewOnlineRecord.gsub(/%%sessionid%%/, sessionid).gsub(/%%userid%%/, userid))
      
      # TODO Make sure that the insert worked.
      
      JSON_LoginSuccessful.gsub(/%%name%%/, name);
    end
    
  # If the email or password is invalid.
  else
    JSON_Error.gsub(/%%error%%/, "Email or password are invalid.");
  end
end

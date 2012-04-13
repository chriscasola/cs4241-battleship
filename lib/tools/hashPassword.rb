=begin
  This file contains functions for hashing the password.
  
  @author Chris Page
  @version 4/12/2012
=end

# Hashes a password
#
# @param [String] password The password to hash.
#
# @return [String] The hashed password.
def hashPassword(password)
  sha256 = Digest::SHA256.new
  hashedPwd = sha256.hexdigest(password)
  return hashedPwd
end
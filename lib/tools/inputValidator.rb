=begin
  This file contains functions for validating user input.
  
  @author Chris Page
  @version 4/12/2012
=end

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
  return true # TODO This is wrong. Finish this function.
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

# Checks whether or not the name is valid.
#
# @param [String] name The name to check.
#
# @return [boolean] True if the name is valid. False otherwise.
def validateName(name)
  if (name == nil)
    return false
  end
  
  return true # TODO This is wrong. Finish this function.
end
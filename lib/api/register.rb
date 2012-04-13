=begin
  This file contains the register api function.
  
  @author Chris Page
  @version 4/12/2012
=end

require 'tools/hashPassword'
require 'tools/inputValidator'
require 'dbmgr'

SQL_SelectEmailFromUsers = 
<<EOS
SELECT email FROM users
WHERE email='%%email%%';
EOS

SQL_SelectNameFromUsers = 
<<EOS
SELECT name FROM users
WHERE name='%%name%%';
EOS

SQL_InsertUserRecord = 
<<EOS
INSERT INTO users (name, email, password)
VALUES ('%%name%%', %%email%%, %%password%%);
EOS

JSON_Output = {'success' => false, 'error' => ''}

 def register (email, password1, password2, name)
    # If the email, password, and name are valid
    if (validateEmail(email) && validatePassword(password1) && validatePassword(password2) && validateName(name))

        # If the passwords match
        if (password1 == password2)
            conn = connectToDB(ENV['SHARED_DATABASE_URL'])

            # Check if email is already in the database
            query = SQL_SelectEmailFromUsers.gsub(/%%email%%/, email)
            results = conn.exec(query)

            # If the email is not already in the database
            if (results.ntuples == 0)
                results.clear()

                # Check if name is already in the database
                query = SQL_SelectNameFromUsers.gsub(/%%name%%/, name)
                results = conn.exec(query)

                # If the name is not already in the database
                if (results.ntuples == 0)
                    # Insert user record
                    query = SQL_InsertUserRecord.gsub(/%%name%%/, name).gsub(/%%email%%/, email).gsub(/%%password%%/, hashPassword(password))
                    results = conn.exec(query)
                    
                    # Record successfully inserted
                    if (results.cmd_tuples() == 1)
                        # return JSON
                        JSON_Output['success'] = true
                        JSON_Output['error'] = ''
                        conn.finish()
                        
                        JSON.generate(JSON_Output)
                        
                    # Record insertion unsuccessful
                    else
                        JSON_Output['success'] = false
                        JSON_Output['error'] = "User record creation failed."
                        conn.finish()
                        
                        JSON.generate(JSON_Output)
                    end

                # If the name is already in the database
                else
                    JSON_Output['success'] = false
                    JSON_Output['error'] = "Name already in use."
                    results.clear()
                    conn.finish()

                    JSON.generate(JSON_Output)
                end

            # If the email is already in the database
            else
                JSON_Output['success'] = false
                JSON_Output['error'] = "Email address already in use."
                results.clear()
                conn.finish()

                JSON.generate(JSON_Output)
            end

        # If the passwords do not match
        else
            JSON_Output['success'] = false
            JSON_Output['error'] = "Passwords do not match."
            JSON.generate(JSON_Output)
        end

    # If the email, password or name is invalid.
    else
        JSON_Output['success'] = false
        JSON_Output['error'] = "Email, password or name is invalid."
        JSON.generate(JSON_Output)
    end
end
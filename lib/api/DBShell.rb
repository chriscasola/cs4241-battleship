=begin
  File to provide a postgre sql shell
  
  @author Chris Casola
  @version 4/23/2012
  
  On 4/23/2012, C. Page converted this to a Sinatra module.
=end

require 'pg'

# This class provides a db shell.
class DBShell < Sinatra::Base
	
	# Handle path for db_manager get
	get '/db_manager' do
	    runDBShell(ENV['SHARED_DATABASE_URL'])
	end
	
	# Handle path for db_manager post
	post '/db_manager' do
	    runDBShell(ENV['SHARED_DATABASE_URL'], params)
	end
	
	# TODO Comment this, maybe split into two functions!!!
	def runDBShell (dbPath, params=nil)
    	if (params == nil)
<<EOS
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8" />
      <title>Database Manager</title>
    </head>
    <body>
      <h1>Enter SQL statements in the box below.</h1>
      <form method="post">
      <textarea name="sqlCode" rows="20" cols="150"></textarea><br /><br />
      <input type="submit" value="Submit">
      </form>
    </body>
  </html>
EOS
	    else
	        conn = connectToDB(dbPath)
	        results = conn.exec(params[:sqlCode])
	        strOut = ''
	        results.each do |row|
	            row.each do |column|
	                strOut = strOut + ' ' + column.to_s
	            end
	        end
	        strOut + '<br /><br /><br /><a href="/db_manager">Enter another query</a>'
	    end
	end
end
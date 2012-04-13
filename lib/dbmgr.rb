#
# File to connect to postgre sql database
#

require 'pg'

def connectToDB(dbPath)
    dbPath =~ %r|^postgres://(\S*):(\S*)@(\S*)/(\S*)$|
    conn = PG::Connection.new( :host => $3, :dbname => $1, :user => $4, :password => $2)
end

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

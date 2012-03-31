/*
 * File to connect to postgre sql database
 */

require 'pg'

def connectToDB(dbPath)
  
=begin
  conn.exec( "SELECT * FROM pg_stat_activity" ) do |result|
    puts "     PID | User             | Query"
    result.each do |row|
    puts " %7d | %-16s | %s " %
    row.values_at('procpid', 'usename', 'current_query')
  end
=end
end

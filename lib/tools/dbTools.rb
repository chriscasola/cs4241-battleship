=begin
  This file contains the DBTools class.
  
  @author Chris Page
  @version 4/14/2012
=end

require 'pg'

# This class contains a method for connecting to the database.
class DBTools
	
	# Connects to the database using the PG gem.
	# This code is from Chris Casola's dbmgr.rb.
	#
	# @param [String, Optional] The path for connecting to the database.
    #
    # @return [Connection] A new PG::Connection object for the specified path.
	def connectToDB(dbPath=ENV['SHARED_DATABASE_URL'])
    	dbPath =~ %r|^postgres://(\S*):(\S*)@(\S*)/(\S*)$|
    	conn = PG::Connection.new( :host => $3, :dbname => $1, :user => $4, :password => $2)
	end
end
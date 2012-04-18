#
# Returns the list of battles a user is participating in
#
# Author: Chris Casola, Chris Page
#

require 'tools/dbTools'
require 'json'

def get_battles(playerid)
	query = "SELECT battleid, p1id AS playerid, startdate, enddate FROM battles WHERE p1id<>#{playerid};"
	conn = DBTools.new.connectToDB()
	result = conn.exec(query)
	response = Array.new
	result.each do |row|
		response << row
	end
	
	query = "SELECT battleid, p2id AS playerid, startdate, enddate FROM battles WHERE p2id<>#{playerid};"
	result = conn.exec(query)
	result.each do |row|
		response << row
	end
	response.to_json
end

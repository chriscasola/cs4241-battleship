#
# Create a new battle
#
# Author: Chris Casola
#

require 'pg'
require 'tools/dbTools'

def new_battle(request)
	dbtools = DBTools.new
	conn = dbtools.connectToDB();
	playerid = dbtools.getPlayerId(session['sessionid']);
	
	query = "INSERT INTO battles VALUES (default, (SELECT userid FROM users WHERE name='#{escape(request)}'), playerid, default, default, default, default);"
	
	begin
		conn.exec(query)
	rescue
		conn.finish()
		return 'error'
	end
	conn.finish()
	return 'success'
end

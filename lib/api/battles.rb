#
# Returns the list of battles a user is participating in
#
# Author: Chris Casola, Chris Page
#

require 'tools/dbTools'
require 'json'

def get_battles()
	if (DBTools.new.getPlayerId(session['sessionid']) == false)
		return 'not logged in'
	else
		playerid = DBTools.new.getPlayerId(session['sessionid']);
	end
	
	query = "SELECT battleid, name AS playerid, startdate, status FROM battles, users WHERE p1id<>#{playerid} AND p1id=userid;"
	conn = DBTools.new.connectToDB()
	result = conn.exec(query)
	response = Array.new
	result.each do |row|
		processBattlesRow(playerid, row, response)
	end
	
	query = "SELECT battleid, name AS playerid, startdate, status FROM battles, users WHERE p2id<>#{playerid} AND p2id=userid;"
	result = conn.exec(query)
	result.each do |row|
		processBattlesRow(playerid, row, response)
	end
	response.to_json
end

def processBattlesRow(playerid, row, response)
	sdate = /\A(\d\d\d\d)-(\d\d)-(\d\d)\s*(\d*):(\d*)/.match(row['startdate'])
	status = /\A\S(\S)(\S*)/.match(row['status'])
	if (status[1] == playerid)
		if (status[2] == 'win')
			status = 'You won'
		else
			status = 'Your turn'
		end
	else
		if (status[2] == 'win')
			status = 'You lost'
		else
			status = row['playerid'] + "'s turn"
		end
	end
	response << {'battleid' => row['battleid'], 'playerid' => row['playerid'], 'syear' => sdate[1], 'smonth' => sdate[2], 'sday' => sdate[3], 'shour' => sdate[4], 'smin' => sdate[5], 'status' => status}
end

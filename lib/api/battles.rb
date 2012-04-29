#
# Returns the list of battles a user is participating in
#
# Author: Chris Casola
#

require 'tools/dbTools'
require 'json'

def get_battles()
	if (DBTools.new.getPlayerId(session['sessionid']) == false)
		return 'not logged in'
	else
		playerid = DBTools.new.getPlayerId(session['sessionid']);
	end
	query = "(SELECT battleid, name AS playerid, p1id, p2id, startdate, status FROM battles, users WHERE p1id=#{playerid} and p2id=userid) "
	query += "UNION "
	query += "(SELECT battleid, name AS playerid, p1id, p2id, startdate, status FROM battles, users WHERE p1id=userid and p2id=#{playerid}) ORDER BY startdate DESC;"
	conn = DBTools.new.connectToDB()
	result = conn.exec(query)
	response = Array.new
	result.each do |row|
		processBattlesRow(playerid, row, response)
	end
	
	response.to_json
end

def create_battle(opponentName)
	if (DBTools.new.getPlayerId(session['sessionid']) == false)
		return 'not logged in'
	else
		playerid = DBTools.new.getPlayerId(session['sessionid']);
	end
	
	begin
		conn = DBTools.new.connectToDB()
		opponentName = conn.escape_string(opponentName);
		conn.transaction do
			query = "INSERT INTO battles VALUES (default, #{playerid}, (SELECT userid FROM users WHERE name='#{opponentName}' AND userid<>#{playerid}), default, default, default, default);"
			conn.exec(query)
			query = "INSERT INTO users_notify VALUES ((SELECT userid FROM users WHERE name='#{opponentName}' LIMIT 1), (SELECT battleid FROM battles ORDER BY battleid DESC LIMIT 1), true);"
			conn.exec(query)
		end
	rescue
		conn.finish()
		return 'invalid'
	end
	conn.finish()
	return 'success'
end

def processBattlesRow(playerid, row, response)
	sdate = /\A([\d*]*)-0*(\d*)-0*(\d*)\s*0*(\d*):(\d*)/.match(row['startdate'])
	status = /\A\S(\S)(\S*)/.match(row['status'])
	
	if (row['p1id'].to_i == playerid.to_i)
		if (status[1].to_i == 1)
			if (status[2] == 'win')
				status = 'You won'
			else
				status = 'Your turn'
			end
		elsif (status[2] == 'win')
			status = 'You lost'
		elsif (status[2] == 'turn')
			status = row['playerid'] + "'s turn"
		end
	elsif (row['p2id'].to_i == playerid.to_i)
		if (status[1].to_i == 2)
			if (status[2] == 'win')
				status = 'You won'
			else
				status = 'Your turn'
			end
		elsif (status[2] == 'win')
			status = 'You lost'
		elsif (status[2] == 'turn')
			status = row['playerid'] + "'s turn"
		end
	end
	
=begin
	if (status[1].to_i == playerid.to_i)
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
=end
	response << {'battleid' => row['battleid'], 'playerid' => row['playerid'], 'syear' => sdate[1], 'smonth' => sdate[2], 'sday' => sdate[3], 'shour' => sdate[4], 'smin' => sdate[5], 'status' => status}
end

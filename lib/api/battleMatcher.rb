=begin
  This file contains the battleMatcher class.
  
  @author Chris Casola
  @version 4/22/2012
=end

require 'tools/dbTools'
require 'json'
require 'api/battles'

###########################################################
# Called by the user's browser to check if the user needs
# to be notified of any new matches
###########################################################
def update_matches
	if (DBTools.new.getPlayerId(session['sessionid']) == false)
		halt(401, 'user not logged in')
	else
		playerid = DBTools.new.getPlayerId(session['sessionid']);
	end
	conn = DBTools.new.connectToDB()
	query = "SELECT battleid, invite FROM users_notify WHERE userid=#{playerid};"
	result = conn.exec(query)
	response = Array.new
	result.each do |row|
		response << {'battleid' => row['battleid'], 'invite' => row['invite']}
	end
	query = "DELETE FROM users_notify WHERE userid=#{playerid};"
	conn.exec(query)
	conn.finish()
	return response.to_json
end

###########################################################
# Called when the user wants to find a match with another
# online player.
###########################################################
def find_battle
	if (DBTools.new.getPlayerId(session['sessionid']) == false)
		halt(401, 'user not logged in')
	else
		playerid = DBTools.new.getPlayerId(session['sessionid']);
	end
	push_onto_waiting(playerid)
	check_for_matches()
	return {'success' => true}.to_json
end

###########################################################
# Check if there are players waiting to be matched and if
# so match them and notify them.
###########################################################
def check_for_matches()
	conn = DBTools.new.connectToDB()
	query = "SELECT userid FROM users_waiting LIMIT 2;"
	result = conn.exec(query)
	if (result.ntuples() == 2)
		p1id = result[0]['userid']
		p2id = result[1]['userid']
		conn.transaction do
			create_battle = "INSERT INTO battles VALUES (default, #{p1id}, #{p2id}, default, default, default, default);"
			conn.exec(create_battle)
			remove_from_waiting = "DELETE FROM users_waiting WHERE userid=#{p1id} OR userid=#{p2id};"
			conn.exec(remove_from_waiting)
			get_battle_id = "SELECT battleid FROM battles ORDER BY battleid DESC LIMIT 1;"
			result = conn.exec(get_battle_id)
			battleid = result[0]['battleid']
			notify_user = "INSERT INTO users_notify VALUES (#{p1id}, #{battleid}, false);"
			conn.exec(notify_user)
			notify_user = "INSERT INTO users_notify VALUES (#{p2id}, #{battleid}, false);"
			conn.exec(notify_user)
		end
	end
	conn.finish()
end

###########################################################
# Pushes the user onto the waiting table
###########################################################
def push_onto_waiting(playerid)
	begin
		query = "INSERT INTO users_waiting VALUES (#{playerid}, default);"
		conn = DBTools.new.connectToDB()
		conn.exec(query)
	rescue
		# user is already in the queue, do nothing
	end
	conn.finish()
end

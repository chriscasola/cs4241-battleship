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
	def connectToDB(dbPath=ENV['DATABASE_URL'])
    	dbPath =~ %r|^postgres://(\S*):(\S*)@(\S*):(\S*)/(\S*)$|
    	conn = PG::Connection.new( :host => $3, :dbname => $1, :user => $5, :password => $2, :port => $4)
	end
	
	# Execute a SQL query
	#
	# @param String the query to execute
	#
	def executeQuery(queryString)
		conn = connectToDB
		result = conn.exec(queryString)
		conn.finish()
		return result
	end
	
	################################################
	# Below are functions that act as wrappers for
	# various SQL queries.  All of these functions
	# return the result of the query they contain
	################################################
	
	# Get the playerid associated with this session
	def getPlayerId(sessionid)
		begin
			query = "SELECT userid FROM users_online WHERE sessionid='#{sessionid}';"
			result = executeQuery(query)
			retVal = result[0]['userid']
			return retVal
		rescue
			return false
		end
	end
	
	# Insert the given ship into the database
	def insertShip(the_ship)
		sql_InsertShip = "INSERT INTO battle_positions
						 VALUES (#{the_ship['battleid']}, #{the_ship['playerid']}, 
						 #{the_ship['xpos']}, #{the_ship['ypos']}, '#{the_ship['stype']}',
						 '#{the_ship['orientation']}', '#{the_ship['afloat']}', 0)"
		executeQuery(sql_InsertShip)
	end
	
	# Get all of the ships associated with the given player and battle
	def getAllUsersShipsInBattle(battleid, playerid)
		query = "SELECT *
				 FROM battle_positions
				 WHERE battleid=#{battleid} AND playerid=#{playerid};"
		executeQuery(query)
	end
	
	# Get all the ships that are sunk, belong to the player with the given
	# id, and in the given battle 
	def getAllOpponentsSunkShipsInBattle(battleid, playerid)
		query = "SELECT *
				 FROM battle_positions
				 WHERE battleid=#{battleid} AND playerid<>#{playerid} AND afloat=false;"
		executeQuery(query)
	end
	
	# Insert a new battle move
	def insertBattleMove(battleid, playerid, xpos, ypos, hit)
		query = "INSERT INTO battle_moves(battleid, playerid, xpos, ypos, hit)
				 VALUES (#{battleid}, #{playerid}, #{xpos}, #{ypos}, #{hit});"
		executeQuery(query)
	end
	
	# Mark a battle as over and store the given status
	def markBattleOver(battleid, status)
		query = "UPDATE battles SET status='#{status}' WHERE battleid=#{battleid};
				 UPDATE battles SET enddate=now() WHERE battleid=#{battleid};"
		executeQuery(query)
	end
end
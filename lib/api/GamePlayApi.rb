=begin
  This file contains the GamePlayApi class.
  
  @author Chris Casola
  @version 4/22/2012
  
  On 4/22/2012, C. Page converted this to a Sinatra module.
=end

require 'sinatra/base'
require 'tools/dbTools'
require 'json'

# This class handles the playing of a battle ship game
class GamePlayApi < Sinatra::Base
	
	enable :sessions

	# Static values for the length of each ship type
	@@Ship_lengths = {'carrier' => 5, 'battleship' => 4, 'submarine' => 3, 'cruiser' => 3, 'destroyer' => 2}
	
	#########################################################
	# Web server routes handled by this class
	#########################################################
	
	# Receives a new shot from the user
	post '/api/shot' do
    	receive_shot(request.body.read)
	end
	
	# Send to the user any shot they do not already have
	post '/api/check_shot' do
	    send_shots(request.body.read)
	end
	
	# Receives a new ship from the user
	post '/api/ship' do
	    receive_ship(request.body.read)
	end
	
	# Sends the user all their ships in the current battle
	get '/api/ship' do
	    send_ships(params[:request])
	end
	
	#########################################################
	# Receives a ship from the user 
	#
	# Handles: POST /api/ship
	#########################################################
	def receive_ship(json_req)
	    the_ship = JSON.parse(json_req)
	    
	    # Get the user's playerid and make sure they are logged in
	    playerid = DBTools.new.getPlayerId(session['sessionid'])
	    if (playerid == false)
	    	return sendErrorResponse('The player is not logged in')
	    else
	    	the_ship['playerid'] = playerid
	    end
	
		# Check that the ship placement is within the bounds of the game board
	    if (check_bounds(the_ship) == false)
	    	return sendErrorResponse('This ship placement would be outside the bounds of the game board.')
	    end
	    
	    # Check that the ship doesn't overlap any other ships
	    if (check_overlap(the_ship) == false)
	    	return sendErrorResponse('This ship placement overlaps another ship.')
	    end
	    
	    begin
	    	# store the ship in db
	    	DBTools.new.insertShip(the_ship)
	    	
	    	# return the ship upon success
	    	return sendResponse([the_ship])
	    rescue
	    	# the ship has already been placed
	    	return sendErrorResponse('You have already placed a ship of this type.')
	    end
	end
	
	##############################################################
	# Check if the given ship overlaps other already placed ships
	#
	# Returns true if there is no overlap, otherwise false
	##############################################################
	def check_overlap(the_ship)
		
		# Get all of the user's ships
		result = DBTools.new.getAllUsersShipsInBattle(the_ship['battleid'], the_ship['playerid'])
		
		# Check if there are any ships, if not no need to check overlap
		if (result.ntuples() == 0)
			return true
		end
		
		# Get the start and end coordinates of the new ship
		ship_loc = get_ship_coordinates(the_ship)
		
		# check each existing ship for overlap with the new ship
		result.each do |row|
			# get the coordinates of the current ship
			row_loc = get_ship_coordinates(row)
			
			# check for overlap when the existing ship is vertical and the new ship is horizontal
			if ((row['orientation'] == 'vertical') && (the_ship['orientation'] == 'horizontal'))
				if ((ship_loc[:beg_y] <= row_loc[:end_y]) && (ship_loc[:beg_y] >= row_loc[:beg_y]))
					if ((row_loc[:beg_x] <= ship_loc[:end_x]) && (row_loc[:beg_x] >= ship_loc[:beg_x]))
						return false
					end
				end
			# check for overlap when the existing ship is horizontal and the new ship is vertical
			elsif ((row['orientation'] == 'horizontal') && (the_ship['orientation'] == 'vertical'))
				if ((row_loc[:beg_y] <= ship_loc[:end_y]) && (row_loc[:beg_y] >= ship_loc[:beg_y]))
					if ((ship_loc[:beg_x] <= row_loc[:end_x]) && (ship_loc[:beg_x] >= row_loc[:beg_x]))
						return false
					end
				end
			# check for overlap when both ships are horizontal
			elsif ((row['orientation'] == 'horizontal') && (the_ship['orientation'] == 'horizontal'))
				if (ship_loc[:beg_y] == row_loc[:beg_y])
					if (((ship_loc[:beg_x] <= row_loc[:end_x]) && (ship_loc[:beg_x] >= row_loc[:beg_x])) || \
						((ship_loc[:end_x] <= row_loc[:end_x]) && (ship_loc[:end_x] >= row_loc[:beg_x])))
						return false
					end
				end
			# check for overlap when both ships are vertical
			elsif ((row['orientation'] == 'vertical') && (the_ship['orientation'] == 'vertical'))
				if (ship_loc[:beg_x] == row_loc[:beg_x])
					if (((ship_loc[:beg_y] <= row_loc[:end_y]) && (ship_loc[:beg_y] >= row_loc[:beg_y])) || \
						((ship_loc[:end_y] <= row_loc[:end_y]) && (ship_loc[:end_y] >= row_loc[:beg_y])))
						return false
					end
				end
			end
		end
		
		# there is no overlap
		return true
	end
	
	##############################################################
	# Return the start and end coordinates of the ship in a hash
	# with the following keys: :beg_x, :beg_y, :end_x, :end_y
	##############################################################
	def get_ship_coordinates(the_ship)
		ship_beg_x = 0
		ship_beg_y = 0
		ship_end_x = 0
		ship_end_y = 0
		if (the_ship['orientation'] == 'vertical')
			ship_beg_x = ship_end_x = the_ship['xpos'].to_i
			ship_beg_y = the_ship['ypos'].to_i
			ship_end_y = ship_beg_y + @@Ship_lengths[the_ship['stype']] - 1
		else
			ship_beg_y = ship_end_y = the_ship['ypos'].to_i
			ship_beg_x = the_ship['xpos'].to_i
			ship_end_x = ship_beg_x + @@Ship_lengths[the_ship['stype']] - 1
		end
		return {:beg_x => ship_beg_x, :beg_y => ship_beg_y, :end_x => ship_end_x, :end_y => ship_end_y}
	end
	
	##############################################################
	# Check if the given ship would be within the bounds of
	# the game board.
	#
	# Returns true if valid, otherwise false
	##############################################################
	def check_bounds(the_ship)
	    if (the_ship['orientation'] == 'vertical')
	        if ((the_ship['xpos'] > 9) || (the_ship['xpos'] < 0))
	            return false
	        elsif ((the_ship['ypos'] + @@Ship_lengths[the_ship['stype']]) >= 11)
	            return false
	        elsif (the_ship['ypos'] < 0)
	            return false
	        end
	    elsif (the_ship['orientation'] == 'horizontal')
	        if ((the_ship['ypos'] > 9) || (the_ship['ypos'] < 0))
	            return false
	        elsif ((the_ship['xpos'] + @@Ship_lengths[the_ship['stype']]) >= 11)
	            return false
	        elsif (the_ship['xpos'] < 0)
	            return false
	        end
	    end
	    return true
	end
	
	##############################################################
	# Sends all of the player's ships in the current battle
	#
	# Handles: GET /api/ship
	##############################################################
	def send_ships(request)
	    state = JSON.parse(request)
	    
	    # Make sure the player is logged in
	    playerid = DBTools.new.getPlayerId(session['sessionid'])
	    if (playerid == false)
	    	return sendErrorResponse('The player is not logged in')
	    end
	    
	    battleid = state['battleid']

	    begin
	    	# Get all the user's ships from the database
	        result = DBTools.new.getAllUsersShipsInBattle(battleid, playerid)
	        if (result.ntuples() > 0)
		        # Put each ship in the response array
		        response = Array.new
		        result.each do |row|
		            response << row
		        end
		        # Send the ships in the response
		        return sendResponse(response)
			else
				# There are no ships to send
				return sendResponse([])
	    	end 
	    rescue
	    	# An error occurred either due to an invalid request or issues with the database
	    	return sendErrorResponse('Could not retrieve your ships!')
	    end
	end
	
	##############################################################
	# Receives a new shot from the player
	#
	# Handles: POST /api/shot
	##############################################################
	def receive_shot(json_req)
	    the_shot = JSON.parse(json_req)
	    
	    # Check if the user is logged in
	    playerid = DBTools.new.getPlayerId(session['sessionid'])
	    if (playerid == false)
	    	return sendErrorResponse('The player is not logged in')
	    else
	    	the_shot['playerid'] = DBTools.new.getPlayerId(session['sessionid'])
	    end
	    
	    # Check that the shot has a valid position
	    if (verify_shot(the_shot) == false)
	    	return sendErrorResponse('')
	    end
	    
	    # Check to make sure it is the player's turn
	    if (is_my_turn(the_shot) == false)
	    	return sendErrorResponse('It is not your turn!')
	    end
	 
	    begin
	    	# Determine if this shot is a hit
	        is_hit!(the_shot)
	    rescue
	    	# Catch the error thrown when all of the opponents ships have not yet been placed
	        return sendErrorResponse('Your opponent has not placed all their ships yet!')
	    end
	    
	    begin
	    	# Store the shot in the database
	    	DBTools.new.insertBattleMove(the_shot["battleid"], the_shot["playerid"], the_shot["xpos"].to_s, the_shot["ypos"].to_s, the_shot["hit"].to_s)
	    rescue
	        return sendErrorResponse('')
	    end
	    
	    # Check if the current player won
	    message = ""
	    if (check_my_win(the_shot) == true)
	    	message = "Congratulations. You won!"
	    end
	    
	    # Return the message and shot
	    return {'success' => 'true', 'message' => message, 'content' => the_shot}.to_json
	end
	
	##############################################################
	# Check if the current player won the game
	##############################################################
	def check_my_win(the_shot)
		result = DBTools.new.getAllOpponentsSunkShipsInBattle(the_shot['battleid'], the_shot['playerid'])
		if (result.ntuples() == 5)
			#File.open('battle.log', 'w') {|f| f.write('a player won') }
			end_battle(the_shot['playerid'], the_shot['battleid'])
			return true
		end
		return false
	end
	
	##############################################################
	# Mark the given battle as over and store the winner
	##############################################################
	def end_battle(playerid, battleid)
		status = 'p' + playerid + 'win';
		DBTools.new.markBattleOver(battleid, status)
	end
	
	# TODO test that the above function, end_battle works correctly with
	# the new DBTools call.  Then proceed to rework this file with the
	# next function.
	
	def is_my_turn(the_shot)
		# Find out whose turn it is
		query = "SELECT p1id, p2id, status FROM battles WHERE battleid=#{the_shot['battleid']};"
		conn = DBTools.new.connectToDB
		result = conn.exec(query)
		my_turn = false
		if ((result[0]['status'] == 'p1turn') && (result[0]['p1id'].to_i == the_shot['playerid'].to_i))
			# It is my turn
			my_turn = true
			
			# Change battle status in database
			query = "UPDATE battles SET status='p2turn' WHERE battleid=#{the_shot['battleid']};"
			conn.exec(query)
			
		elsif ((result[0]['status'] == 'p2turn') && (result[0]['p2id'].to_i == the_shot['playerid'].to_i))
			# It is my turn
			my_turn = true
			
			# Change battle status in database
			query = "UPDATE battles SET status='p1turn' WHERE battleid=#{the_shot['battleid']};"
			conn.exec(query)
			
		else
			# It is not my turn
			my_turn = false
		end
		conn.finish()
		return my_turn
	end
	
	def is_hit!(the_shot)
	    conn = DBTools.new.connectToDB
		is_sunk = false
	    # Get all the opponent's ships
	    query = "SELECT battleid, playerid, xpos, ypos, stype, orientation FROM battle_positions WHERE battleid=#{the_shot['battleid']} AND playerid<>#{the_shot['playerid']};"
	    result = conn.exec(query)
	    if (result.ntuples() < 5)
	    	conn.finish()
	        raise
	    end
		the_shot['hit'] = false
		#File.open('battle.log', 'a') {|f| f.write("***************************\n") }
		#File.open('battle.log', 'a') {|f| f.write("The shot: " + the_shot.to_json + "\n") }
	    result.each do |row|
	    	#File.open('battle.log', 'a') {|f| f.write("Current row: " + row.to_json + "\n") }
	        if ((row['orientation'] == 'horizontal') && # deals with checking horizontally placed ships
	            (row['ypos'].to_i == the_shot['ypos'].to_i) && # check if the y positions match
	            (the_shot['xpos'].to_i < row['xpos'].to_i + @@Ship_lengths[row['stype']]) && # check if the x position is within the ship
	            (the_shot['xpos'].to_i >= row['xpos'].to_i))
	            #File.open('battle.log', 'a') {|f| f.write("Found match with horizontal ship\n") }
	            is_sunk = increment_hits(row, conn)
				the_shot['hit'] = true
				#File.open('battle.log', 'a') {|f| f.write("The shot: " + the_shot.to_json + "\n") }
	            break
	        elsif ((row['orientation'] == 'vertical'))# deal with vertically placed ships
	            if ((row['xpos'].to_i == the_shot['xpos'].to_i) && # check if x positions match
					(the_shot['ypos'].to_i < row['ypos'].to_i + @@Ship_lengths[row['stype']]) && # check if the y position is within the ship
					(the_shot['ypos'].to_i >= row['ypos'].to_i))
					#File.open('battle.log', 'a') {|f| f.write("Found match with vertical ship\n") }
		            is_sunk = increment_hits(row, conn)
		            the_shot['hit'] = true
		            #File.open('battle.log', 'a') {|f| f.write("The shot: " + the_shot.to_json + "\n") }
		            break
	            end
	        end
	    end
	    #File.open('battle.log', 'a') {|f| f.write("***************************\n") }
	    conn.finish()
	end
	
	def increment_hits(the_ship, conn)
		query = "UPDATE battle_positions SET numhits=(numhits + 1) WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']} AND stype='#{the_ship['stype']}';"
		conn.exec(query)
		query = "SELECT numhits FROM battle_positions WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']} AND stype='#{the_ship['stype']}';"
		result = conn.exec(query)
		if (result[0]['numhits'].to_i == @@Ship_lengths[the_ship['stype']])
			query = "UPDATE battle_positions SET afloat='false' WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']} AND stype='#{the_ship['stype']}';"
			conn.exec(query)
			return true
		end
		return false
	end
	
	def send_shots(request)
	    state = JSON.parse(request)
	    
	    if (DBTools.new.getPlayerId(session['sessionid']) == false)
	    	return sendErrorResponse('You are not logged in!')
	    else
	    	state['playerid'] = DBTools.new.getPlayerId(session['sessionid'])
	    end
	    
	    query =
<<EOS
SELECT moveid AS id, battleid, playerid, xpos, ypos, hit
FROM battle_moves
WHERE moveid>#{state['last_shot']}
AND battleid=#{state['battleid']};
EOS
	
	    conn = DBTools.new.connectToDB
	    begin
	        result = conn.exec(query)
	    rescue
	        conn.finish()
	        return sendErrorResponse('A server error occurred in the send_ships method.')
	    end
	    if (result.ntuples() > 0)
	        response = Array.new
	        message = ""
	        result.each do |row|
	            response << row
	        end
	        if (check_win(conn, state['battleid'], state['playerid']))
	        	message = 'You lost the game!'
	        end
	    	conn.finish()
	    	return {'success' => 'true', 'message' => message, 'content' => response}.to_json
	    else
	        response = {'success' => 'true', 'message' => '', 'content' => []}.to_json
	    	conn.finish()
	    	return response
	    end
	end
	
	def check_win(conn, battleid, playerid)
		query = "SELECT stype FROM battle_positions WHERE battleid=#{battleid} AND playerid=#{playerid} AND afloat=false;"
		result = conn.exec(query)
		if (result.ntuples() == 5)
			return true
		else
			return false
		end
	end
	
	def verify_shot(the_shot)
	    if ((the_shot["xpos"] > 9) || (the_shot["xpos"] < 0) || (the_shot["ypos"] > 9) || (the_shot["ypos"] < 0))
	    	return false
	    end
	    return true
	end
end

def sendResponse(message)
	return {'success' => 'true', 'message' => message}.to_json
end

def sendErrorResponse(message)
	return {'success' => 'false', 'message' => message}.to_json
end

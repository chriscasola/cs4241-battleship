#
# File to handle the playing of a battle ship game
#
# Author: Chris Casola, Chris Page
#

require 'api/dbmgr'
require 'json'

SQL_InsertBattleMove =
<<EOS
INSERT INTO battle_moves(battleid, playerid, xpos, ypos, hit)
VALUES (%%battleid%%, %%playerid%%, %%xpos%%, %%ypos%%, %%hit%%);
EOS

Ship_lengths = {'carrier' => 5, 'battleship' => 4, 'submarine' => 3, 'cruiser' => 3, 'destroyer' => 2}

def receive_ship(json_req)
    the_ship = JSON.parse(json_req)

    if (check_bounds(the_ship) == false)
        return 'invalid'
    end
    
    if (check_overlap(the_ship) == false)
    	return 'invalid'
    end
    
    sql_InsertShip = 
<<EOS
INSERT INTO battle_positions
VALUES (#{the_ship['battleid']}, #{the_ship['playerid']}, #{the_ship['xpos']}, #{the_ship['ypos']}, '#{the_ship['stype']}', '#{the_ship['orientation']}', '#{the_ship['afloat']}', 0)
EOS
    
    begin
    #store the ship in db
        conn = connectToDB(ENV['SHARED_DATABASE_URL'])
        conn.exec(sql_InsertShip)
        conn.finish()
    rescue
        conn.finish()
        return 'invalid'
    end
    return the_ship.to_json
end

def check_overlap(the_ship)
	query = "SELECT xpos, ypos, stype, orientation FROM battle_positions WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']};"
	conn = connectToDB(ENV['SHARED_DATABASE_URL'])
	result = conn.exec(query)
	
	# Check if there are any ships, if not no need to check overlap
	if (result.ntuples() == 0)
		return true
	end
	
	ship_loc = get_ship_coordinates(the_ship)
	
	# check each existing ship for overlap
	result.each do |row|
		row_loc = get_ship_coordinates(row)
		if ((row['orientation'] == 'vertical') && (the_ship['orientation'] == 'horizontal'))
			if ((ship_loc[:beg_y] <= row_loc[:end_y]) && (ship_loc[:beg_y] >= row_loc[:beg_y]))
				if ((row_loc[:beg_x] <= ship_loc[:end_x]) && (row_loc[:beg_x] >= ship_loc[:beg_x]))
					return false
				end
			end
		elsif ((row['orientation'] == 'horizontal') && (the_ship['orientation'] == 'vertical'))
			if ((row_loc[:beg_y] <= ship_loc[:end_y]) && (row_loc[:beg_y] >= ship_loc[:beg_y]))
				if ((ship_loc[:beg_x] <= row_loc[:end_x]) && (ship_loc[:beg_x] >= row_loc[:beg_x]))
					return false
				end
			end
		elsif ((row['orientation'] == 'horizontal') && (the_ship['orientation'] == 'horizontal'))
			if (ship_loc[:beg_y] == row_loc[:beg_y])
				if (((ship_loc[:beg_x] <= row_loc[:end_x]) && (ship_loc[:beg_x] >= row_loc[:beg_x])) || \
					((ship_loc[:end_x] <= row_loc[:end_x]) && (ship_loc[:end_x] >= row_loc[:beg_x])))
					return false
				end
			end
		elsif ((row['orientation'] == 'vertical') && (the_ship['orientation'] == 'vertical'))
			if (ship_loc[:beg_x] == row_loc[:beg_x])
				if (((ship_loc[:beg_y] <= row_loc[:end_y]) && (ship_loc[:beg_y] >= row_loc[:beg_y])) || \
					((ship_loc[:end_y] <= row_loc[:end_y]) && (ship_loc[:end_y] >= row_loc[:beg_y])))
					return false
				end
			end
		end
	end
	return true
end

def get_ship_coordinates(the_ship)
	# get the start and end coordinates of the_ship
	ship_beg_x = 0
	ship_beg_y = 0
	ship_end_x = 0
	ship_end_y = 0
	if (the_ship['orientation'] == 'vertical')
		ship_beg_x = ship_end_x = the_ship['xpos'].to_i
		ship_beg_y = the_ship['ypos'].to_i
		ship_end_y = ship_beg_y + Ship_lengths[the_ship['stype']] - 1
	else
		ship_beg_y = ship_end_y = the_ship['ypos'].to_i
		ship_beg_x = the_ship['xpos'].to_i
		ship_end_x = ship_beg_x + Ship_lengths[the_ship['stype']] - 1
	end
	return {:beg_x => ship_beg_x, :beg_y => ship_beg_y, :end_x => ship_end_x, :end_y => ship_end_y}
end

def check_bounds(the_ship)
    if (the_ship['orientation'] == 'vertical')
        if ((the_ship['xpos'] > 9) || (the_ship['xpos'] < 0))
            return false
        elsif ((the_ship['ypos'] + Ship_lengths[the_ship['stype']]) >= 11)
            return false
        elsif (the_ship['ypos'] < 0)
            return false
        end
    elsif (the_ship['orientation'] == 'horizontal')
        if ((the_ship['ypos'] > 9) || (the_ship['ypos'] < 0))
            return false
        elsif ((the_ship['xpos'] + Ship_lengths[the_ship['stype']]) >= 11)
            return false
        elsif (the_ship['xpos'] < 0)
            return false
        end
    end
    return true
end

def send_ships(request)
    state = JSON.parse(request)
    battleid = state['battleid']
    playerid = state['playerid']
    query = "SELECT * FROM battle_positions WHERE battleid=#{battleid} AND playerid=#{playerid};"
    conn = connectToDB(ENV['SHARED_DATABASE_URL'])
    begin
        result = conn.exec(query)
    rescue
        conn.finish()
        return 'error'
    end
    if (result.ntuples() > 0)
        response = Array.new
        result.each do |row|
            response << {'battleid' => row['battleid'], 'playerid' => row['playerid'], 'xpos' => row['xpos'], 'ypos' => row['ypos'], 'stype' => row['stype'], 'orientation' => row['orientation'], 'afloat' => row['afloat']}
        end
        conn.finish()
        return response.to_json
    else
        response = 'none'
        conn.finish()
        return response
    end 
end

def receive_shot(json_req)
    the_shot = JSON.parse(json_req)
    
    if (verify_shot(the_shot) == false)
        return 'invalid'
    end
    
    if (is_my_turn(the_shot) == false)
    	return 'not your turn'
    end
 
    begin
        is_hit!(the_shot)
    rescue
        return 'ships_missing'
    end
    
    begin
    #store the shot in db
        conn = connectToDB(ENV['SHARED_DATABASE_URL'])
        query = SQL_InsertBattleMove.gsub(/%%battleid%%/, the_shot["battleid"])
        query = query.gsub(/%%playerid%%/, the_shot["playerid"])
        query = query.gsub(/%%xpos%%/, the_shot["xpos"].to_s)
        query = query.gsub(/%%ypos%%/, the_shot["ypos"].to_s)
        query = query.gsub(/%%hit%%/, the_shot["hit"].to_s)
        conn.exec(query)
    rescue
        conn.finish()
        return 'invalid'
    end
    
    check_win!(conn, the_shot)
    
    conn.finish()
    return the_shot.to_json
end

def check_win!(conn, the_shot)
	query = "SELECT stype FROM battle_positions WHERE battleid=#{the_shot['battleid']} AND playerid<>#{the_shot['playerid']} AND afloat=false;"
	result = conn.exec(query)
	if (result.ntuples() == 5)
		the_shot['win'] = true
		update_battle_status(the_shot['playerid'], the_shot['battleid'], conn)
	end
end

def update_battle_status(playerid, battleid, conn)
	status = 'p' + playerid + 'win';
	query = "UPDATE battles SET status='#{status}' WHERE battleid=#{battleid}; "
	query += "UPDATE battles SET enddate=now() WHERE battleid=#{battleid};"
	conn.exec(query)
end

def is_my_turn(the_shot)
	# Find out whose turn it is
	query = "SELECT p1id, p2id, status FROM battles WHERE battleid=#{the_shot['battleid']};"
	conn = connectToDB(ENV['SHARED_DATABASE_URL'])
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
    conn = connectToDB(ENV['SHARED_DATABASE_URL'])
	is_sunk = false
    # Get all the opponent's ships
    query = "SELECT battleid, playerid, xpos, ypos, stype, orientation FROM battle_positions WHERE battleid=#{the_shot['battleid']} AND playerid<>#{the_shot['playerid']};"
    result = conn.exec(query)
    if (result.ntuples() < 5)
    	conn.finish()
        raise
    end

    result.each do |row|
        if ((row['orientation'] == 'horizontal') && # deals with checking horizontally placed ships
            (row['ypos'].to_i == the_shot['ypos'].to_i) && # check if the y positions match
            (the_shot['xpos'].to_i < row['xpos'].to_i + Ship_lengths[row['stype']]) && # check if the x position is within the ship
            (the_shot['xpos'].to_i >= row['xpos'].to_i))
            is_sunk = increment_hits(row, conn)
			the_shot['hit'] = true
            break
        else # deal with vertically placed ships
            if ((row['xpos'].to_i == the_shot['xpos'].to_i) && # check if x positions match
				(the_shot['ypos'].to_i < row['ypos'].to_i + Ship_lengths[row['stype']]) && # check if the y position is within the ship
				(the_shot['ypos'].to_i >= row['ypos'].to_i))
	            is_sunk = increment_hits(row, conn)
	            the_shot['hit'] = true
	            break
            end
        end
    end
    conn.finish()
    the_shot['sunk'] = is_sunk
end

def increment_hits(the_ship, conn)
	query = "UPDATE battle_positions SET numhits=(numhits + 1) WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']} AND stype='#{the_ship['stype']}';"
	conn.exec(query)
	query = "SELECT numhits FROM battle_positions WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']} AND stype='#{the_ship['stype']}';"
	result = conn.exec(query)
	if (result[0]['numhits'].to_i == Ship_lengths[the_ship['stype']])
		query = "UPDATE battle_positions SET afloat='false' WHERE battleid=#{the_ship['battleid']} AND playerid=#{the_ship['playerid']} AND stype='#{the_ship['stype']}';"
		conn.exec(query)
		return true
	end
	return false
end

def send_shots(request)
    state = JSON.parse(request)
    query =
<<EOS
SELECT moveid, battleid, playerid, xpos, ypos, hit
FROM battle_moves
WHERE moveid>#{state['last_shot']}
AND battleid=#{state['battleid']};
EOS

    conn = connectToDB(ENV['SHARED_DATABASE_URL'])
    begin
        result = conn.exec(query)
    rescue
        conn.finish()
        return 'error'
    end
    if (result.ntuples() > 0)
        response = Array.new
        response << {'message' => ''}
        result.each do |row|
            response << {'battleid' => row['battleid'], 'playerid' => row['playerid'], 'xpos' => row['xpos'], 'ypos' => row['ypos'], 'hit' => row['hit'], 'id' => row['moveid']}
        end
        if (check_win(conn, state['battleid'], state['playerid']))
        	response[0]['message'] = 'lost'
        end
    	conn.finish()
    	return {'type' => 'shot', 'content' => response}.to_json
    else
        response = {'type' => 'info', 'message' => 'none'}.to_json
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

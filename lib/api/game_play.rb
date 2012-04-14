require 'api/dbmgr'
require 'json'

SQL_InsertBattleMove =
<<EOS
INSERT INTO battle_moves(battleid, playerid, xpos, ypos, hit)
VALUES (%%battleid%%, %%playerid%%, %%xpos%%, %%ypos%%, %%hit%%);
EOS

Ship_lengths = {'carrier' => 5, 'battleship' => 4, 'submarine' => 3, 'cruiser' => 3, 'destroyer' => 2}

# TODO deal with keeping tack of which player's turn it is, who can fire a shot

def receive_ship(json_req)
    the_ship = JSON.parse(json_req)

    if (check_bounds(the_ship) == false)
        return 'invalid'
    end
    
    if (check_overlap(the_ship) == false)
    	return 'invalid'
    end
    
    # TODO make sure the ship doesn't overlap any other ships
    
    sql_InsertShip = 
<<EOS
INSERT INTO battle_positions
VALUES (#{the_ship['battleid']}, #{the_ship['playerid']}, #{the_ship['xpos']}, #{the_ship['ypos']}, '#{the_ship['stype']}', '#{the_ship['orientation']}', '#{the_ship['afloat']}')
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
        conn.finish()
    rescue
        conn.finish()
        return 'invalid'
    end
    return the_shot.to_json
end

def is_hit!(the_shot)
    conn = connectToDB(ENV['SHARED_DATABASE_URL'])

    # Get all the opponent's ships
    query = "SELECT xpos, ypos, stype, orientation FROM battle_positions WHERE battleid=#{the_shot['battleid']} AND playerid<>#{the_shot['playerid']};"
    result = conn.exec(query)
    if (result.ntuples() < 5)
    	conn.finish()
        raise
    end

    result.each do |row|
        if (row['orientation'] == 'horizontal')
            if (row['ypos'].to_i == the_shot['ypos'].to_i)
            	if (the_shot['xpos'].to_i < row['xpos'].to_i + Ship_lengths[row['stype']])
                    if (the_shot['xpos'].to_i >= row['xpos'].to_i)
                        the_shot['hit'] = true
                        break
                    end
                end
            end
        else
            if (row['xpos'].to_i == the_shot['xpos'].to_i)
                if (the_shot['ypos'].to_i < row['ypos'].to_i + Ship_lengths[row['stype']])
                    if (the_shot['ypos'].to_i >= row['ypos'].to_i)
                        the_shot['hit'] = true
                        break
                    end
                end
            end
        end
    end
    conn.finish()
    # TODO update the afloat value if necessary
    # TODO if ship is sunk, alert the ship's owner
end

def send_shots(request)
    state = JSON.parse(request)
    query =
<<EOS
SELECT moveid, battleid, playerid, xpos, ypos, hit
FROM battle_moves
WHERE moveid > #{state['last_shot']}
AND battleid = #{state['battleid']};
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
        result.each do |row|
            response << {'battleid' => row['battleid'], 'playerid' => row['playerid'], 'xpos' => row['xpos'], 'ypos' => row['ypos'], 'hit' => row['hit'], 'id' => row['moveid']}
        end
    conn.finish()
    return response.to_json
    else
        response = 'none'
    conn.finish()
    return response
    end
end

def verify_shot(the_shot)
    if ((the_shot["xpos"] > 9) || (the_shot["xpos"] < 0) || (the_shot["ypos"] > 9) || (the_shot["ypos"] < 0))
    	return false
    end
    return true
end

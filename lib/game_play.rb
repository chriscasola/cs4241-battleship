require 'dbmgr'
require 'json'

SQL_InsertBattleMove =
<<EOS
INSERT INTO battle_moves(battleid, playerid, xpos, ypos, hit)
VALUES (%%battleid%%, %%playerid%%, %%xpos%%, %%ypos%%, %%hit%%);
EOS

def receive_ship(json_req)
    the_ship = JSON.parse(json_req)

    if (check_bounds(the_ship) == false)
        return 'invalid'
    end
    
    # TODO make sure the user hasn't already placed a ship of this type
    
    # TODO make sure the ship doesn't overlap any other ships
    
    sql_InsertShip = 
<<EOS
INSERT INTO battle_positions
VALUES (#{the_ship['battleid']}, #{the_ship['playerid']}, #{the_ship['xpos']}, #{the_ship['ypos']}, '#{the_ship['shiptype']}', '#{the_ship['orientation']}', '#{the_ship['afloat']}')
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

def check_bounds(the_ship)
    ship_lengths = {'carrier' => 5, 'battleship' => 4, 'submarine' => 3, 'cruiser' => 3, 'destroyer' => 2}
    if (the_ship['orientation'] == 'vertical')
        if ((the_ship['xpos'] > 9) || (the_ship['xpos'] < 0))
            return false;
        elsif ((the_ship['ypos'] + ship_lengths[the_ship['shiptype']]) >= 11)
            return false;
        elsif (the_ship['ypos'] < 0)
            return false;
        end
    elsif (the_ship['orientation'] == 'horizontal')
        if ((the_ship['ypos'] > 9) || (the_ship['ypos'] < 0))
            return false;
        elsif ((the_ship['xpos'] + ship_lengths[the_ship['shiptype']]) >= 11)
            return false;
        elsif (the_ship['xpos'] < 0)
            return false;
        end
    end
end

def send_ships()
    
end

def receive_shot(json_req)
    the_shot = JSON.parse(json_req)
    if (rand(100) < 30)
        the_shot["hit"] = true
    else
        the_shot["hit"] = false
    end

    if (verify_shot(the_shot) == false)
        return 'invalid'
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

def send_shots(last_received)
    query =
    <<EOS
SELECT moveid, battleid, playerid, xpos, ypos, hit
FROM battle_moves
WHERE moveid > #{last_received};
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

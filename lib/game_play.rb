
require 'dbmgr'
require 'json'

SQL_InsertBattleMove = 
<<EOS
INSERT INTO battle_moves(battleid, playerid, xpos, ypos, hit)
VALUES (%%battleid%%, %%playerid%%, %%xpos%%, %%ypos%%, %%hit%%);
EOS

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

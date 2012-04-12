
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
  
  #store the shot in db
  conn = connectToDB(ENV['SHARED_DATABASE_URL'])
  query = SQL_InsertBattleMove.gsub(/%%battleid%%/, the_shot["battleid"])
  query = query.gsub(/%%playerid%%/, the_shot["playerid"])
  query = query.gsub(/%%xpos%%/, the_shot["xpos"].to_s)
  query = query.gsub(/%%ypos%%/, the_shot["ypos"].to_s)
  query = query.gsub(/%%hit%%/, the_shot["hit"].to_s)
  begin
    conn.exec(query)
  rescue
    return 'invalid'
    conn.finish()
  end
  conn.finish()
  return the_shot.to_json
end

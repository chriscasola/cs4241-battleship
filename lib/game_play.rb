
require 'json'

def receive_shot(json_req)
  the_shot = JSON.parse(json_req)
  if (rand(100) < 30)
    the_shot["hit"] = true
  else
    the_shot["hit"] = false
  end
  the_shot.to_json
end

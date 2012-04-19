=begin
  This file contains the LeaderboardApi class.
  
  @author Chris Page
  @version 4/19/2012
=end

require 'sinatra/base'
require 'json'
require 'tools/dbTools'

# This class handles the server-side login stuff.
class LeaderboardApi < Sinatra::Base
	
	# SQL statement for counting the number of wins per user
	@@SQL_CountWinsPerUser = 
<<EOS
SELECT userid, name, sum(count) as numwins FROM
((SELECT userid, name, count(battleid) FROM battles, users WHERE userid=p1id AND status='p1win' GROUP BY name, userid)
UNION
(SELECT userid, name, count(battleid) FROM battles, users WHERE userid=p2id AND status='p2win' GROUP BY name, userid)) AS foo GROUP BY name, userid ORDER BY numwins DESC LIMIT 10;
EOS
	
	# Path for leaderboard api post
    post '/api/leaderboard' do
  		leaderboard()
	end
	
	# Returns a list of users with the most wins
	def leaderboard()
		conn = DBTools.new.connectToDB()
		
		# get the number of wins per user
        query = @@SQL_CountWinsPerUser
        results = conn.exec(query)
        
        response = Array.new
        
        # construct response
        results.each do |row|
        	response << {'userid' => Integer(row['userid']), 'name' => row['name'], 'numwins' => Integer(row['numwins'])}
        end
        
        # clear results and close db connection
        results.clear()
        conn.finish()
        
        # respond
        response.to_json
	end
end
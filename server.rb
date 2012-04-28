=begin
  # TODO This comment
  
  @author Chris Casola
  @author Chris Page
  @version 4/13/2012
=end

# http://www.sinatrarb.com/intro.html
# http://www.sinatrarb.com/extensions.html
# http://stackoverflow.com/questions/5015471/using-sinatra-for-larger-projects-via-multiple-files <-- forget this for now

# Add the lib directory to the search path
$: << File.expand_path(File.dirname(__FILE__) + "/lib")

require 'sinatra'
#require 'api/dbmgr'
require 'api/LoginApi'
require 'api/RegisterApi'
require 'api/LeaderboardApi'
#require 'api/GamePlayApi'
require 'api/DBShell'
require 'api/game_play'
require 'api/battles'
require 'api/battleMatcher'
require 'json'

set :static, true
set :public, File.dirname(__FILE__) + '/public'

use LoginApi
use RegisterApi
use LeaderboardApi
#use GamePlayApi
use DBShell

get '/' do
    redirect 'http://' + request.host_with_port() + '/index.html'
end

get '/test' do
    unless (request.env['HTTP_X_FORWARDED_PROTO'] || request.env['rack.url_scheme'])=='https'
        redirect 'https://' + request.host_with_port() + '/test'
    end
    'success!'
end

post '/api/shot' do
    receive_shot(request.body.read)
end

post '/api/check_shot' do
    send_shots(request.body.read)
end

post '/api/ship' do
    receive_ship(request.body.read)
end

post '/api/get_ships' do
    send_ships(request.body.read)
end

get '/api/my_battles' do
	get_battles()
end

post '/api/create_battle' do
	create_battle(request.body.read)
end

post '/api/find_battle' do
	find_battle()
end

get '/api/update_matches' do
	update_matches()
end

#get '/db_manager' do
#    runDBShell(ENV['SHARED_DATABASE_URL'])
#end

#post '/db_manager' do
#    runDBShell(ENV['SHARED_DATABASE_URL'], params)
#end

get '*' do
    "Path: " + request.fullpath()
end

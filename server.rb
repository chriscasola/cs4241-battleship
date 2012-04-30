=begin
  This is the main server for the web app.
  
  @author Chris Casola
  @author Chris Page
  @version 4/30/2012
=end

# Add the lib directory to the search path
$: << File.expand_path(File.dirname(__FILE__) + "/lib")

require 'sinatra'
require 'api/LoginApi'
require 'api/RegisterApi'
require 'api/LeaderboardApi'
require 'api/GamePlayApi'
require 'api/DBShell'
require 'api/UserModule'
require 'api/battles'
require 'api/battleMatcher'
require 'json'

set :static, true
set :public, File.dirname(__FILE__) + '/public'

# Use a whole bunch of Sinatra modules
use LoginApi
use RegisterApi
use LeaderboardApi
use GamePlayApi
use DBShell		# Insecure!
use UserModule

# Handler for GET requests for the root directory
get '/' do
    redirect 'http://' + request.host_with_port() + '/index.html'
end

# Handler for GET requests for /test. Here we were testing SSL. In the future, it would be a good idea to use SSL for this website.
get '/test' do
    unless (request.env['HTTP_X_FORWARDED_PROTO'] || request.env['rack.url_scheme'])=='https'
        redirect 'https://' + request.host_with_port() + '/test'
    end
    'success!'
end

# Handler for GET requests for the path /api/my_battles
get '/api/my_battles' do
	get_battles()
end

# Handler for POST requests for the path /api/create_battle
post '/api/create_battle' do
	create_battle(request.body.read)
end

# Handler for POST requests for the path /api/find_battle
post '/api/find_battle' do
	find_battle()
end

# Handler for GET requests for the path /api/update_matches
get '/api/update_matches' do
	update_matches()
end

# Handler for misc GET requests
get '*' do
    "Path: " + request.fullpath()
end

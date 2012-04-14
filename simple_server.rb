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

require 'sinatra/base'
require 'api/dbmgr'
require 'api/login'
require 'api/register'
require 'api/game_play'
require 'json'

#4567

 class BattleShip < Sinatra::Base
 	set :static, true
    set :public, File.dirname(__FILE__) + '/public'

    use LoginApi

    #configure do
    #  enable :sessions
    #end
    
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

    get '/db_manager' do
        runDBShell(ENV['SHARED_DATABASE_URL'])
    end

    post '/db_manager' do
        runDBShell(ENV['SHARED_DATABASE_URL'], params)
    end

    get '*' do
        "Path: " + request.fullpath()
    end

end

BattleShip.run!

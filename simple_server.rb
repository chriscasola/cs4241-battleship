##
# This is a simple Web server, mainly for serving static content with some JavaScript in order
# to get started building a Web site.
#
# Chris Casola
# Chris Page
##

# Add the lib directory to the search path
$: << File.expand_path(File.dirname(__FILE__) + "/lib")

require 'sinatra'
require 'dbmgr'
require 'login'

set :public_folder, File.dirname(__FILE__) + '/public'

configure do
  enable :sessions
end

get '/' do
  redirect 'http://' + request.host_with_port() + '/index.html'
end

get '/test' do
  unless (request.env['HTTP_X_FORWARDED_PROTO'] || request.env['rack.url_scheme'])=='https'
    redirect 'https://' + request.host_with_port() + '/test'
  end
  'success!'
end

# TODO: change this to post
get '/api/login' do
  login(params[:email], params[:password])
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

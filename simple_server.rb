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
require 'db_connect'

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  redirect 'http://' + request.host_with_port() + '/index.html'
end

get '/db_path' do
  SHARED_DATABASE_URL
  #connectToDB(DATABASE_URL)
end

get '*' do
  "Path: " + request.fullpath()
end

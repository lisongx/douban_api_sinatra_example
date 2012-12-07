require 'rubygems'
require 'sinatra'
require 'haml'
require 'douban_api'
# Helpers
require './lib/render_partial'

enable :sessions
# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public_folder, 'public'
set :callback_url, "http://doubanapi.notimportant.org/connect"
set :scope, "douban_basic_common,shuo_basic_r,shuo_basic_w"


# Set Douban api key & secret
Douban.configure do |config|
  config.client_id = ENV['DOUBAN_API_KEY']
  config.client_secret = ENV['DOUBAN_API_SECRET']
end


get '/' do
  haml :index, :layout => :'layouts/application'
end

get '/login' do
  redirect Douban.authorize_url(:redirect_uri => settings.callback_url, :scope => settings.scope)
end

get '/connect' do
  response = Douban.get_access_token(params[:code], :redirect_uri => settings.callback_url)
  session[:access_token] = response.access_token
  session[:user_id] = response.douban_user_id
  redirect "/timeline"
end

get '/timeline' do
  @client = Douban.client(:access_token => session[:access_token], :user_id => session[:user_id])
  @statuses = @client.timeline
  haml :timeline, :layout => :'layouts/application'
end
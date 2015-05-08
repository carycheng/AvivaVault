require 'rubygems'
require 'bundler'

Bundler.require

Dotenv.load

set :cache, Dalli::Client.new(ENV["MEMCACHIER_SERVERS"],
                  {:username => ENV["MEMCACHIER_USERNAME"],
                   :password => ENV["MEMCACHIER_PASSWORD"],
                   :namespace => ENV["DEMO_APP_NAME"]})

require 'sass/plugin/rack'
Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

enable :sessions
set :session_secret, ENV['SESSION_KEY']
use Rack::Session::Pool, :key => ENV['SESSION_KEY']

use OmniAuth::Builder do
  provider(
    :auth0,
    ENV['AUTH0_CLIENT_ID'],
    ENV['AUTH0_CLIENT_SECRET'],
    ENV['AUTH0_DOMAIN'],
    callback_path: "/auth0/callback"
  )
end

require './app'
run Sinatra::Application

#from the commandline run 'shotgun' in development, or 'rackup' in production
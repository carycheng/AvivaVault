require 'rubygems'
require 'bundler'

Bundler.require

Dotenv.load

set :cache, Dalli::Client.new(ENV["MEMCACHIER_SERVERS"],
                  {:username => ENV["MEMCACHIER_USERNAME"],
                   :password => ENV["MEMCACHIER_PASSWORD"],
                   :namespace => ENV["MEMCACHIER_NAMESPACE"]})

set :sessions, true
set :session_secret, ENV['SESSION_SECRET']

require 'sass/plugin/rack'
Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

require './app'
run Sinatra::Application

#from the commandline run 'shotgun' in development, or 'rackup' in production
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
use Rack::Session::Pool, :key => ENV['SESSION_KEY']

use OmniAuth::Builder do
  provider(
    :auth0,
    'VaSfetcgp9KQew7ylcvxmv0EEkJcmXcd',
    'wFzonPSEJflKmoEN3YT1bbPADy2agtJMWAyhlFc47qFvU4r-_tFnr_DnkpG5aR8A',
    'platform-demo-sinatra-template.auth0.com',
    callback_path: "/auth0/callback"
  )
end

require './app'
run Sinatra::Application

#from the commandline run 'shotgun' in development, or 'rackup' in production
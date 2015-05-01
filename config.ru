require 'rubygems'
require 'bundler'

Bundler.require

Dotenv.load

require 'sass/plugin/rack'
require './app'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run Sinatra::Application

#from the commandline run 'shotgun' in development, or 'rackup' in production
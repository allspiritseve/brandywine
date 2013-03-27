require 'rubygems'
require 'sinatra'

require './app'

use Rack::ShowExceptions

run BrandyWine::Application.new

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :development)

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].each do |file|
  require file
end

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each do |file|
  require file
end

require './app'

use Rack::ShowExceptions

run BrandyWine::Application.new

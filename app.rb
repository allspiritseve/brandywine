require 'sinatra/base'

module BrandyWine
  class Application < Sinatra::Base
    get '/' do
      erb :index
    end
  end
end

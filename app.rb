require 'sinatra/base'


module BrandyWine
  class Application < Sinatra::Base
    set :database, 'postgresql://cory@localhost/brandywine_development'

    get '/' do
      erb :index
    end

    get '/posts' do
      @posts = Post.all
      erb :posts
    end

    get '/tweets' do
      @tweets = Twitter.home_timeline
      erb :tweets
    end

    post '/posts' do

      redirect to('/')
    end
  end
end

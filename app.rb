require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :development)

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].each do |file|
  require file
end

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each do |file|
  require file
end

use Rack::ShowExceptions

module BrandyWine
  class Application < Sinatra::Base
    enable :sessions

    helpers do
      def current_user
        @__current_user ||= set_current_user
      end

      def set_current_user
        return unless session[:user_id]
        User.find(session[:user_id]).tap do |user|
          session.delete(:user_id) unless user
        end
      end

      def require_authentication!
        return if current_user
        not_authenticated
      end

      def not_authenticated
        throw(:halt, [401, "Not authorized\n"])
      end

      def auto_link(string)
        return unless string
        urls = string.scan(/(?:https?:\/\/|www)[^\s]+/)
        urls.each do |url|
          string.sub! url, "<a href=\"#{url}\">#{url}</a>"
        end
        string
      end
    end

    get '/' do
      erb :index
    end

    get '/login' do
      erb :login
    end

    get '/logout' do
      session.delete(:user_id)
      redirect to('/login')
    end

    post '/login' do
      @user = User.find_by_email(params[:email])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect to('/posts')
      else
        redirect to('/login')
      end
    end

    get '/posts' do
      @posts = Post.river
      @posts.published unless current_user
      erb :posts
    end

    get '/posts/:id' do
      @post = Post.find(params[:id])
      erb :post
    end

    get '/tweets' do
      @tweets = Twitter.home_timeline
      erb :tweets
    end

    post '/posts' do
      require_authentication!
      @post = Post.new(params[:post])
      @post.mark_as_published
      if @post.save
        Twitter.update(@post.text)
      end
      redirect to('/posts')
    end
  end
end

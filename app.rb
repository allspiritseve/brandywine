require 'sinatra/base'


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
    end

    get '/' do
      erb :index
    end

    get '/login' do
      erb :login
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
      @posts = Post.order('posted_at DESC, created_at DESC')
      erb :posts
    end

    get '/tweets' do
      @tweets = Twitter.home_timeline
      erb :tweets
    end

    post '/posts' do
      @post = Post.new(params[:post])
      @post.save
      redirect to('/posts')
    end
  end
end

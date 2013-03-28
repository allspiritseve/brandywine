File.expand_path('../', __FILE__).tap do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require 'config/init'
require 'sinatra/activerecord'

require 'lib/auth_helper'
require 'lib/post'
require 'lib/user'

module Brandywine
  class Application < Sinatra::Base
    enable :sessions
    helpers Brandywine::AuthHelper
    helpers Sinatra::JSON
    register Sinatra::ActiveRecordExtension
    use Rack::ShowExceptions

    helpers do
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

    get '/feeds' do
      erb :feeds
    end

    get '/posts.xml' do
      @posts = Post.river.published
      builder do |xml|
        xml.instruct! :xml, :version => '1.0'
        xml.rss :version => '2.0', 'xmlns:microblog' => 'http://microblog.reallysimple.org/' do
          xml.channel do
            xml.author "Cory Kaufman-Schofield"
            xml.link "http://rivers.corykaufman.com/posts"
            xml.description "Cory's feed"
            xml.updated Time.now.to_s
            xml.title "Cory Kaufman-Schofield on Brandywine"
          end
          @posts.each do |post|
            xml.item do
              xml.description post.text
              xml.link "http://rivers.corykaufman.com/posts/#{post.id}"
              xml.guid "http://rivers.corykaufman.com/posts/#{post.id}"
              xml.pubDate post.published_at.to_s
            end
          end
        end
      end
    end

    get '/posts.json' do
      @posts = Post.river.published
      items = @posts.map do |post|
        {
          :description => post.text,
          :link => "http://rivers.corykaufman.com/posts/#{post.id}",
          :guid => "http://rivers.corykaufman.com/posts/#{post.id}",
          :pubDate => post.published_at.to_s
        }
      end
      json :rss => {
        :version => '2.0',
        :channel => {
          :author => "Cory Kaufman-Schofield",
          :link => "http://rivers.corykaufman.com/posts",
          :description => "Cory's feed",
          :updated => Time.now.to_s,
          :title => "Cory Kaufman-Schofield on Brandywine",
          :item => items
        }
      }
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

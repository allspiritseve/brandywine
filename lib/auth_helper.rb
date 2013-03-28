module Brandywine
  module AuthHelper
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
end

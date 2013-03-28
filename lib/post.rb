class Post < ActiveRecord::Base

  before_save :set_posted_at

  def posted_at
    super || created_at
  end

  def set_posted_at
    posted_at ||= created_at
  end

end

class Post < ActiveRecord::Base

  scope :river, order('posts.published_at DESC, posts.created_at DESC')
  scope :published, where('posts.published_at IS NOT NULL')

  def published?
    published_at?
  end

  def draft?
    !published?
  end

  def mark_as_published
    self.published_at ||= Time.now
  end

end

class Comment < ActiveRecord::Base
  include ScopedByDateInterval

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates_presence_of :body
  validates_presence_of :user

  scope :desc, order("created_at DESC")

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user, :counter_cache => true

  attr_accessible :tipo, :body

  scope :de_user_ativo,
              :include => [:user],
              :conditions => ["users.state = 'active'"]

  scope :dos_topicos, lambda { |topico_ids|
    if topico_ids.nil?
      { }
    else
      {
        :conditions => [ "commentable_type = 'Topico' AND commentable_id IN (?)", topico_ids ]
      }
    end
  }

  scope :by_topic, where(:commentable_type => "Topico")

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.user_id = user_id
    c
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.size > 0
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def topico
    commentable if commentable_type == "Topico"
  end

  def topico_id
    commentable_id if commentable_type == "Topico"
  end
end

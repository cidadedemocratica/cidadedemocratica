class Inspiration < ActiveRecord::Base
  belongs_to :competition
  belongs_to :user, :counter_cache => true

  attr_accessible :title, :description, :image

  scope :desc, order("created_at DESC")

  validates_presence_of :title, :description, :image

  mount_uploader :image, ImageUploader
end

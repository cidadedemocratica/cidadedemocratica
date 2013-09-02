class UserAuthorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user, :user_id

  belongs_to :user
  validates :provider, :uid, :presence => true
end

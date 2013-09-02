class CompetitionPrize < ActiveRecord::Base
  attr_accessible :description, :name, :competition_id, :offerer_id, :winning_topic_id

  belongs_to :competition
  belongs_to :offerer, :class_name => "User"
  belongs_to :winning_topic, :class_name => "Topico"

  validates_presence_of :name, :description, :competition_id, :offerer
end

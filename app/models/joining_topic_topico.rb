class JoiningTopicTopico < ActiveRecord::Base
  attr_accessible :joining_topic_id, :topico_id

  belongs_to :topico
  belongs_to :joining_topic
end

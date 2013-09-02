class AprovedJoiningTopicPostman
  attr_accessor :joining_topic

  def initialize(joining_topic)
    self.joining_topic = joining_topic
  end

  def deliver
    JoiningTopicMailer.aproved_to_author(joining_topic.id).deliver

    joining_topic.usuarios_que_seguem.each do |u|
      JoiningTopicMailer.aproved_to_follower(joining_topic.id, u.id).deliver if u.active?
    end
  end
end

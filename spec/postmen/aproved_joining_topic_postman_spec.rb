require 'spec_helper'

describe AprovedJoiningTopicPostman do
  describe 'delivers mail' do
    let!(:joining_topic) { FactoryGirl.create(:joining_topic_aproved) }
    let!(:topico) { joining_topic.topicos_from[0] }
    let!(:topico_joined) { joining_topic.topicos_from[1] }

    let!(:follower1) { FactoryGirl.create(:user) }
    let!(:follower2) { FactoryGirl.create(:user) }

    let!(:postman) { AprovedJoiningTopicPostman.new(joining_topic) }
    let!(:mail) { double('mail') }

    before do
      FactoryGirl.create(:seguido, user: follower1, topico: topico)
      FactoryGirl.create(:seguido, user: follower2, topico: topico_joined)      
    end

    it 'to joining_topic author' do
      JoiningTopicMailer.should_receive(:aproved_to_author).with(joining_topic.id).and_return(mail)    
      JoiningTopicMailer.should_receive(:aproved_to_author).any_number_of_times.and_return(mail)

      mail.should_receive(:deliver).exactly(1).times
      postman.deliver
    end

    it 'to each follower' do
      JoiningTopicMailer.should_receive(:aproved_to_follower).with(joining_topic.id, follower1.id).and_return(mail)
      JoiningTopicMailer.should_receive(:aproved_to_follower).with(joining_topic.id, follower2.id).and_return(mail)
      JoiningTopicMailer.should_receive(:aproved_to_follower).any_number_of_times.and_return(mail)
      
      mail.should_receive(:deliver).exactly(2).times
      postman.deliver
    end
  end
end

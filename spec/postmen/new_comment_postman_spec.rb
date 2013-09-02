require 'spec_helper'

describe NewCommentPostman do
  describe 'delivers mail' do
    let!(:owner) { FactoryGirl.create(:user) }
    let!(:commenter) { FactoryGirl.create(:user) }
    let!(:proposta) { FactoryGirl.create(:proposta, user: owner) }
    let!(:follower1) { FactoryGirl.create(:user) }
    let!(:follower2) { FactoryGirl.create(:user) }
    let!(:seguido) { FactoryGirl.create(:seguido, user: follower1, topico: proposta) }
    let!(:seguido2) { FactoryGirl.create(:seguido, user: follower2, topico: proposta) }
    let!(:comment) { FactoryGirl.create(:comment, commentable: proposta, user: commenter) }
    let!(:postman) { NewCommentPostman.new(proposta, comment) }
    let!(:mail) { double('mail') }

    before do
      mail.should_receive(:deliver).exactly(3).times
    end

    it 'to topic owner' do
      TopicoMailer.should_receive(:new_comment).with(owner.id, proposta.id, comment.id).and_return(mail)
      TopicoMailer.should_receive(:new_comment).any_number_of_times.and_return(mail)

      postman.deliver
    end

    it 'to each follower' do
      TopicoMailer.should_receive(:new_comment).with(follower1.id, proposta.id, comment.id).and_return(mail)
      TopicoMailer.should_receive(:new_comment).with(follower2.id, proposta.id, comment.id).and_return(mail)
      TopicoMailer.should_receive(:new_comment).any_number_of_times.and_return(mail)

      postman.deliver
    end
  end
end

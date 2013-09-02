require 'spec_helper'

describe CompetitionsController do
  before do
    subject.stub(:set_competition_meta_tags).and_return {}
  end

  describe 'GET /show' do
    context 'inspiration phase' do
      let(:competition) do
        FactoryGirl.create(:competition_in_inspiration_phase)
      end

      let(:user) { FactoryGirl.create(:user) }

      it 'render inspiration_phase template' do
        get 'show', :id => competition.id
        response.should render_template('inspiration_phase')
      end

      it 'assigns inspirations' do
        inspiration =
          FactoryGirl.create(:inspiration, :competition => competition, :user => user)

        get 'show', :id => competition.id
        assigns(:inspirations).should include(inspiration)
      end
    end

    %w(proposals_phase support_phase joining_phase announce_phase).each do |phase|
      before { subject.stub(:proposals_phases) }
      context phase do
        let(:competition) { FactoryGirl.create("competition_in_#{phase}") }

        it "render #{phase} template" do
          get 'show', :id => competition.id
          response.should render_template(phase)
        end
      end
    end
  end
end

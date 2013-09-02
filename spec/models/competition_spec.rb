require 'spec_helper'

describe Competition do
  let!(:competition) { FactoryGirl.create(:competition) }

  before do
    competition.inspiration_phase = 2
    competition.proposals_phase = 3
    competition.support_phase = 4
    competition.joining_phase = 5
    competition.announce_phase = 6
  end

  describe 'associations' do
    it { should have_many(:inspirations) }
    it { should have_many(:proposals).class_name("Proposta") }
  end

  describe 'default phases' do
    it 'sets each phase to 18 days' do
      competition.set_default_phases

      Competition::PHASES.each do |phase|
        competition.send(phase).should == 18
      end
    end
  end

  describe 'first phase' do
    it 'is inspiration' do
      competition.start_date = 0.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :inspiration_phase

      competition.start_date = 1.day.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :inspiration_phase

      competition.finished?.should == false
    end
  end

  describe 'second phase' do
    it 'is proposals' do
      competition.start_date = 2.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :proposals_phase

      competition.start_date = 4.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :proposals_phase

      competition.finished?.should == false
    end
  end

  describe 'third phase' do
    it 'is support' do
      competition.start_date = 5.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :support_phase

      competition.start_date = 8.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :support_phase

      competition.finished?.should == false
    end
  end

  describe 'forth phase' do
    it 'is joining' do
      competition.start_date = 9.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :joining_phase

      competition.start_date = 13.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :joining_phase

      competition.finished?.should == false
    end
  end

  describe 'fifth phase' do
    it 'is announce' do
      competition.start_date = 14.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :announce_phase

      competition.start_date = 19.days.ago.to_date
      competition.calculate_current_phase
      competition.current_phase.should == :announce_phase

      competition.finished?.should == false
    end
  end

  describe 'after last phase' do
    it 'is finished' do
      competition.start_date = 20.days.ago.to_date
      competition.calculate_current_phase.should == :announce_phase
      competition.current_phase.should == :announce_phase

      competition.finished?.should == true
    end

    it 'is finished without last phase' do
      competition.announce_phase = 0

      competition.start_date = 14.days.ago.to_date
      competition.calculate_current_phase.should == :joining_phase
      competition.current_phase.should == :joining_phase

      competition.finished?.should == true
    end
  end

  describe 'supporting proposals' do
    it 'is allowed during support phase' do
      competition_in_support_phase = FactoryGirl.create(:competition_in_support_phase)

      competition_in_support_phase.supports_allowed?.should == true
    end

    it 'is not allowed during proposal phase' do
      competition_in_proposals_phase = FactoryGirl.create(:competition_in_proposals_phase)

      competition_in_proposals_phase.supports_allowed?.should == false
    end

    it 'is not allowed during joining phase' do
      competition_in_joining_phase = FactoryGirl.create(:competition_in_joining_phase)

      competition_in_joining_phase.supports_allowed?.should == false
    end
  end

  describe '#future_phase?' do
    it 'indicates if a given phase happens after the current one' do
      competition = FactoryGirl.build(:competition_in_inspiration_phase)
      competition.future_phase?(:proposals_phase).should be_true
    end
  end

  describe '#phase_enabled?' do
    Competition::PHASES.each do |phase|
      it "indicates that #{phase} is enabled when days is greaer than zero" do
        competition = FactoryGirl.build(:competition, phase => 1)
        competition.phase_enabled?(phase).should be_true
      end

      it "indicates that #{phase} is disabled when days is equals to zero" do
        competition = FactoryGirl.build(:competition, phase => 0)
        competition.phase_enabled?(phase).should be_false
      end
    end
  end

  describe '.finished' do
    it 'returns finished competitions' do
      finished_competition =
        FactoryGirl.create(:competition_in_announce_phase, :finished => true)

        Competition.finished.should include(finished_competition)
    end
  end

  describe '#prizes_with_defined_winning_topic' do
    let!(:competition) { FactoryGirl.create(:competition) }
    let!(:winning_topic) { FactoryGirl.create(:proposta, :competition => competition) }
    let!(:competition_prize) { FactoryGirl.create(:competition_prize,  :winning_topic => winning_topic ,:competition => competition) }

    it 'returns prizes which has winning topic defined' do
      competition.prizes_with_defined_winning_topic.should eq [competition_prize]
    end
  end

  describe 'phase is over' do
    it 'before current' do
      competition.current_phase = :proposals_phase

      competition.phase_over?(:inspiration_phase).should be_true
    end

    it 'after current' do
      competition.current_phase = :support_phase

      competition.phase_over?(:announce_phase).should be_false
    end

    it 'current' do
      competition.current_phase = :joining_phase

      competition.phase_over?(:joining_phase).should be_false
    end
  end

  describe 'expiration date from' do
    it { competition.expiration_date_from(:inspiration_phase).should == 2.days.from_now.to_date }
    it { competition.expiration_date_from(:proposals_phase).should == 5.days.from_now.to_date }
    it { competition.expiration_date_from(:support_phase).should == 9.days.from_now.to_date }
    it { competition.expiration_date_from(:joining_phase).should == 14.days.from_now.to_date }
    it { competition.expiration_date_from(:announce_phase).should == 20.days.from_now.to_date }
  end

  describe 'without participants' do
    it { competition.participants.size.should == 0 }
  end

  describe 'with participants' do
    let(:proposal) { FactoryGirl.create(:competition_proposal) }
    let(:competition) { proposal.competition }
    it 'returns topics author' do
      competition.participants.size.should == 1
      competition.participants.map(&:id).should include(proposal.user_id)
    end
    it 'returns inspirations' do
      inspiration = FactoryGirl.create(:inspiration)
      competition.inspirations << inspiration

      competition.participants.size.should == 2
      competition.participants.map(&:id).should include(inspiration.user_id)
    end
    it 'returns comments author' do
      comment = FactoryGirl.create(:comment)
      proposal.comment_threads << comment

      competition.participants.size.should == 2
      competition.participants.map(&:id).should include(comment.user_id)
    end
    it 'returns adesoes user' do
      adesao = FactoryGirl.create(:adesao, :topico => proposal)

      competition.participants.size.should == 2
      competition.participants.map(&:id).should include(adesao.user_id)
    end
    it 'returns seguido user' do
      seguido = FactoryGirl.create(:seguido, :topico => proposal)

      competition.participants.size.should == 2
      competition.participants.map(&:id).should include(seguido.user_id)
    end
  end
end

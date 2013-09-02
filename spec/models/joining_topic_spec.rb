require 'spec_helper'

describe JoiningTopic do
  let!(:joining_topic) { FactoryGirl.create(:joining_topic) }

  describe 'associations'  do
    it { should belong_to(:user) }
    it { should have_many(:topicos_from) }
    it { should have_one(:topico_to) }
  end

  describe 'validate presence' do
    it { should validate_presence_of(:current_phase) }
    it { should validate_presence_of(:user) }
  end

  describe 'validate topicos_from' do
    describe 'pass with two topicos' do
      it { joining_topic.should be_valid }
    end

    describe 'error without topicos' do
      before do
        joining_topic.topicos_from.destroy_all
      end
      it { joining_topic.should_not be_valid }
    end

    describe 'error with more tham two' do
      before do
        joining_topic.topicos_from << FactoryGirl.create(:competition_proposal)
      end
      it { joining_topic.should_not be_valid }
    end
  end

  describe 'competition belongs to topico' do
    let!(:proposta)             { FactoryGirl.create(:proposta) }
    let!(:competition_proposal) { FactoryGirl.create(:competition_proposal) }

    describe 'topico without competition' do
      before do
        joining_topic.topicos_from = [proposta]
      end

      it { joining_topic.competition.should be_nil }
    end

    describe 'topico with competition' do
      before do
        joining_topic.topicos_from = [competition_proposal]
      end

      it { joining_topic.competition.should == competition_proposal.competition }
    end
  end

  describe 'can not be edited' do
    describe 'if expired' do
      before do
        joining_topic.current_phase = :author_phase
        joining_topic.competition.start_date = 200.days.ago
      end
      it { joining_topic.author_phase?.should be_true }
      it { joining_topic.can_be_edited?.should be_false }
    end

    describe 'if in incorrect phase' do
      before do
        joining_topic.current_phase = :pending_phase
      end
      it { joining_topic.expired?.should be_false }
      it { joining_topic.can_be_edited?.should be_false }
    end
  end

  describe 'can be edited' do
    before do
      joining_topic.current_phase = :author_phase
    end
    it { joining_topic.can_be_edited?.should be_true }
  end

  describe 'can not be evaluated' do
    describe 'if expired' do
      before do
        joining_topic.current_phase = :pending_phase
        joining_topic.competition.start_date = 200.days.ago
      end
      it { joining_topic.pending_phase?.should be_true }
      it { joining_topic.can_be_evaluated?.should be_false }
    end

    describe 'if in incorrect phase' do
      before do
        joining_topic.current_phase = :author_phase
      end
      it { joining_topic.expired?.should be_false }
      it { joining_topic.can_be_evaluated?.should be_false }
    end
  end

  describe 'can be evaluated' do
    before do
      joining_topic.current_phase = :pending_phase
    end
    it { joining_topic.can_be_evaluated?.should be_true }
  end

  describe 'expiration' do
    describe 'without competition' do
      before do
        joining_topic.topicos_from[0].competition = nil
      end

      it { joining_topic.expiration_date.should be_nil }
      it { joining_topic.expired?.should be_nil }
    end

    describe 'with competition' do
      before do
        joining_topic.competition.inspiration_phase = 2
        joining_topic.competition.proposals_phase = 3
        joining_topic.competition.support_phase = 4
        joining_topic.competition.joining_phase = 5
      end

      describe 'expired' do
        before do
          joining_topic.competition.start_date = 20.days.ago
        end
        it { joining_topic.expiration_date.should == 6.days.ago.to_date }
        it { joining_topic.expired?.should be_true }
      end

      describe 'expiration date in future' do
        it { joining_topic.expiration_date.should == 14.days.from_now.to_date }
        it { joining_topic.expired?.should be_false }
      end
    end
  end

  describe 'coauthor, is_author?, author_topico and coauthor_topico -' do
    let!(:topico)        { joining_topic.topicos_from[0] }
    let!(:topico_joined) { joining_topic.topicos_from[1] }

    it { joining_topic.is_author?(topico.user).should be_false }
    it { joining_topic.author_topico.should be_nil }
    it { joining_topic.coauthor_topico.should be_nil }

    describe 'author of topico' do
      before do
        joining_topic.author = topico.user
      end

      it { joining_topic.is_author?(topico.user).should be_true }
      it { joining_topic.coauthor.should == topico_joined.user }
      it { joining_topic.author_topico.should == topico }
      it { joining_topic.coauthor_topico.should == topico_joined }
    end

    describe 'author of topico joined' do
      before do
        joining_topic.author = topico_joined.user
      end

      it { joining_topic.is_author?(topico_joined.user).should be_true }
      it { joining_topic.coauthor.should == topico.user }
      it { joining_topic.author_topico.should == topico_joined }
      it { joining_topic.coauthor_topico.should == topico }
    end

    describe 'same author' do
      before do
        joining_topic.author = topico.user
        topico_joined.user = topico.user
      end

      it { joining_topic.is_author?(topico.user).should be_true }
      it { joining_topic.coauthor.should == topico_joined.user }
      it { joining_topic.author_topico.should_not == joining_topic.coauthor_topico }
    end
  end

  describe 'tags' do
    describe 'topicos without tags' do
      before do
        joining_topic.topicos_from[0].tags.destroy_all
        joining_topic.topicos_from[1].tags.destroy_all
      end

      it { joining_topic.tags.should == [] }
    end

    describe 'topicos with same tags' do
      it { joining_topic.tags[0].name.should == "tag1" }
      it { joining_topic.tags[1].name.should == "tag2" }
      it { joining_topic.tags.size.should == 2 }
    end
  end

  describe 'locais' do
    describe 'topicos without locais' do
      before do
        joining_topic.topicos_from[0].locais.destroy_all
        joining_topic.topicos_from[1].locais.destroy_all
      end

      it { joining_topic.locais.should == [] }
    end

    describe 'topicos with same locais' do
      before do
        local = joining_topic.topicos_from[0].locais[0]
        local.pais_id = 1
        local.estado_id = 1
        local.cidade_id = 1
        local.bairro_id = 1

        local2 = joining_topic.topicos_from[1].locais[0]
        local2.pais_id = 1
        local2.estado_id = 1
        local2.cidade_id = 1
        local2.bairro_id = 1

        joining_topic.topicos_from[0].locais = [local]
        joining_topic.topicos_from[1].locais = [local2]
      end

      it { joining_topic.locais.size.should == 1 }
    end

    describe 'topicos with brasil in locais' do
      before do
        local = joining_topic.topicos_from[0].locais[0]
        local.pais_id = 1
        local.estado_id = 0
        local.cidade_id = 0
        local.bairro_id = 0

        local2 = joining_topic.topicos_from[1].locais[0]
        local2.pais_id = 1
        local2.estado_id = 1
        local2.cidade_id = 1
        local2.bairro_id = 1

        joining_topic.topicos_from[0].locais = [local]
        joining_topic.topicos_from[1].locais = [local2]
      end

      it { joining_topic.locais[0].estado_id == 0 }
      it { joining_topic.locais.size == 1 }
    end

    describe 'topicos with two different states' do
      before do
        local = joining_topic.topicos_from[0].locais[0]
        local.pais_id = 1
        local.estado_id = 2
        local.cidade_id = 0
        local.bairro_id = 0

        local2 = joining_topic.topicos_from[1].locais[0]
        local2.pais_id = 1
        local2.estado_id = 1
        local2.cidade_id = 0
        local2.bairro_id = 0

        joining_topic.topicos_from[0].locais = [local]
        joining_topic.topicos_from[1].locais = [local2]
      end

      it { joining_topic.locais.size == 2 }
    end

    describe 'topicos with state and city' do
      before do
        local = joining_topic.topicos_from[0].locais[0]
        local.pais_id = 1
        local.estado_id = 2
        local.cidade_id = 0
        local.bairro_id = 0

        local2 = joining_topic.topicos_from[1].locais[0]
        local2.pais_id = 1
        local2.estado_id = 2
        local2.cidade_id = 1
        local2.bairro_id = 0

        joining_topic.topicos_from[0].locais = [local]
        joining_topic.topicos_from[1].locais = [local2]
      end

      it { joining_topic.locais[0].estado_id == 2 }
      it { joining_topic.locais.size == 1 }
    end
  end

  describe 'usuários que seguem' do
    let(:user1) { FactoryGirl.create(:cidadao) }
    let(:user2) { FactoryGirl.create(:cidadao) }
    before do
      FactoryGirl.create(:seguido, :user => user1, :topico => joining_topic.topicos_from[0])
      FactoryGirl.create(:seguido, :user => user2, :topico => joining_topic.topicos_from[0])
      FactoryGirl.create(:seguido, :user => user1, :topico => joining_topic.topicos_from[1])
    end

    it { joining_topic.usuarios_que_seguem.size == 2 }
    it { joining_topic.usuarios_que_seguem.should include(user1) }
    it { joining_topic.usuarios_que_seguem.should include(user2) }
  end

  describe 'usuarios que aderem' do
    let(:user1) { FactoryGirl.create(:cidadao) }
    let(:user2) { FactoryGirl.create(:cidadao) }
    before do
      FactoryGirl.create(:adesao, :user => user1, :topico => joining_topic.topicos_from[0])
      FactoryGirl.create(:adesao, :user => user2, :topico => joining_topic.topicos_from[0])
      FactoryGirl.create(:adesao, :user => user1, :topico => joining_topic.topicos_from[1])
    end

    it { joining_topic.usuarios_que_aderem.size == 2 }
    it { joining_topic.usuarios_que_aderem.should include(user1) }
    it { joining_topic.usuarios_que_aderem.should include(user2) }
  end
end

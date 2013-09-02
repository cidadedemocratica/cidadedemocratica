require 'spec_helper'

describe JoiningTopicsController do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:joining_topic) { FactoryGirl.create(:joining_topic) }
  let!(:competition_in_joining_phase) { FactoryGirl.create(:competition_in_joining_phase) }

  def joining_topic_in_author_phase_and_user_like_author
    joining_topic.current_phase = :author_phase
    joining_topic.author = user
    joining_topic.topicos_from[0].user = user
    joining_topic.topicos_from[0].save!
    joining_topic.save!
  end

  def joining_topic_in_author_phase_and_user_like_coauthor
    joining_topic.current_phase = :author_phase
    joining_topic.author = joining_topic.topicos_from[0].user
    joining_topic.topicos_from[1].user = user
    joining_topic.topicos_from[1].save!
    joining_topic.save!
  end

  def joining_topic_in_pending_phase_and_user_like_author
    joining_topic.title = Forgery(:basic).text
    joining_topic.description = Forgery(:basic).text
    joining_topic.current_phase = :pending_phase
    joining_topic.author = user
    joining_topic.topicos_from[0].user = user
    joining_topic.topicos_from[0].save!
    joining_topic.save!
  end

  def joining_topic_in_pending_phase_and_user_like_coauthor
    joining_topic.title = Forgery(:basic).text
    joining_topic.description = Forgery(:basic).text
    joining_topic.current_phase = :pending_phase
    joining_topic.author = joining_topic.topicos_from[0].user
    joining_topic.topicos_from[1].user = user
    joining_topic.topicos_from[1].save!
    joining_topic.save!
  end

  before do
    joining_topic.topicos_from[0].competition = competition_in_joining_phase
    joining_topic.save!
    sign_in user
  end

  describe 'new and create' do
    let!(:proposal) { FactoryGirl.create(:competition_proposal, id: 3) }
    let!(:proposal_joined) { FactoryGirl.create(:competition_proposal, id: 4) }
    let!(:proposal_related) { FactoryGirl.create(:competition_proposal) }

    describe '#new' do
      before do
        Topico.stub(:find).with("3").and_return(proposal)
        proposal.stub(:joining_related).and_return([proposal_related])
      end

      describe 'when proposal cannot be joined' do
        before do
          proposal.stub(:can_be_joined?).and_return(false)
          get :new, topico_id: 3
        end

        it 'redirects to topic page' do
          should redirect_to(topico_path(proposal))
        end

        it { should set_the_flash[:warning].to('Esse tópico não pode ser unido') }
      end

      describe 'when proposal can be joined' do
        before do
          proposal.stub(:can_be_joined?).and_return(true)
          get :new, topico_id: 3
        end

        it 'does not redirect' do
          should_not redirect_to(topicos_url(:topico_type => "topicos"))
        end

        it 'assigns a new joining topic' do
          assigns[:joining_topic].should_not be_nil
          assigns[:joining_topic].should be_new_record
        end

        it 'assigns the chosen topic to the joining topic' do
          assigns[:joining_topic].topicos_from[0].should == proposal
        end
      end
    end

    describe '#create' do
      before do
        mailer = double
        mailer.should_receive(:deliver)
        JoiningTopicMailer.should_receive(:created).with(an_instance_of(Fixnum)).and_return(mailer)

        post :create, :joining_topic => { :topicos_from_attributes => [ { id: 3 }, { id: 4 } ] }
      end

      it 'should save the joining topic correctly' do
        joining_topic = JoiningTopic.last
        joining_topic.current_phase.should == :propose_phase
        joining_topic.topicos_from[0].should == proposal
        joining_topic.topicos_from[1].should == proposal_joined
      end

      it 'should redirect to first topico page after save' do
        should redirect_to(topico_path(proposal))
      end

      it { should set_the_flash[:notice].to('Sua sugestão de união foi cadastrada com sucesso') }
    end
  end

  describe '#preview' do
    describe 'restricted to everyone' do
      before do
        get :preview, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted to co-author' do
      before do
        joining_topic_in_pending_phase_and_user_like_coauthor
        get :preview, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be edited' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :preview, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser editada') }
    end

    describe 'authorized to author' do
      before do
        joining_topic_in_author_phase_and_user_like_author
        get :preview, id: joining_topic.id
      end

      it { should_not redirect_to(root_path) }
      it { response.should render_template('preview') }
    end
  end

  describe '#title_update' do
    describe 'restricted to everyone' do
      before do
        get :title_update, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be edited' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :title_update, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser editada') }
    end

    describe 'authorized to author' do
      before do
        joining_topic_in_author_phase_and_user_like_author
      end

      describe 'save it' do
        before do
          put :title_update, :id => joining_topic.id, :joining_topic => { :title => 'test' }
          joining_topic.reload
        end

        it { should redirect_to(description_edit_joining_topic_path(joining_topic)) }
        it { joining_topic.title.should == 'test' }
      end

      describe 'warning' do
        before do
          put :title_update, :id => joining_topic.id, :joining_topic => { :title => '' }
        end

        it { should set_the_flash[:warning].to('Você deve preencher o novo título') }
        it { should redirect_to(title_edit_joining_topic_path(joining_topic)) }
      end
    end
  end

  describe '#description_edit' do
    describe 'restricted to everyone' do
      before do
        get :description_edit, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be edited' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :description_edit, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser editada') }
    end

    describe 'redirect if resource doesnt have title' do
      before do
        joining_topic_in_author_phase_and_user_like_author
        get :description_edit, :id => joining_topic.id
      end
      it { should redirect_to(title_edit_joining_topic_path(joining_topic)) }
    end
  end

  describe '#description_update' do
    describe 'restricted to everyone' do
      before do
        get :description_update, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be edited' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :description_update, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser editada') }
    end

    describe 'redirect if resource doesnt have title' do
      before do
        joining_topic_in_author_phase_and_user_like_author
        put :description_update, :id => joining_topic.id, :joining_topic => { :description => 'test' }
      end
      it { should redirect_to(title_edit_joining_topic_path(joining_topic)) }
    end

    describe 'warning without description' do
      before do
        joining_topic.title = "title"
        joining_topic_in_author_phase_and_user_like_author
        put :description_update, :id => joining_topic.id, :joining_topic => { :description => '' }
      end

      it { should set_the_flash[:warning].to('Você deve preencher a nova descrição') }
      it { should redirect_to(description_edit_joining_topic_path(joining_topic)) }
    end

    describe 'save' do
      before do
        mailer = double
        mailer.should_receive(:deliver)
        JoiningTopicMailer.should_receive(:pending_phase).with(joining_topic.id).and_return(mailer)

        joining_topic.title = "title"
        joining_topic.description = "description"
        joining_topic_in_author_phase_and_user_like_author
        put :description_update, :id => joining_topic.id, :joining_topic => { :description => 'test' }
        joining_topic.reload
      end

      it { joining_topic.pending_phase?.should be_true }
      it { joining_topic.description.should == 'test' }
      it { should set_the_flash[:notice].to('Proposta enviada para avaliação do co-autor') }
      it { should redirect_to(joining_topic_path(joining_topic)) }
    end
  end

  describe '#show' do
    describe 'restricted to everyone' do
      before do
        get :show, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'authorized to author' do
      before do
        joining_topic_in_author_phase_and_user_like_author
        get :show, id: joining_topic.id
      end

      it { should_not redirect_to(root_path) }
      it { response.should render_template('show') }
    end

    describe 'authorized to coauthor' do
      before do
        joining_topic_in_pending_phase_and_user_like_coauthor
        get :show, id: joining_topic.id
      end

      it { should_not redirect_to(root_path) }
      it { response.should render_template('show') }
    end

    describe 'redirects to created topico and keep flash' do
      let(:notice) { Forgery(:basic).text }
      let(:topico_created) { FactoryGirl.create(:competition_proposal) }
      before do
        joining_topic.topico_to = topico_created
        joining_topic_in_pending_phase_and_user_like_coauthor
        get :show, id: joining_topic.id
        flash[:notice] = notice
      end

      it { should redirect_to(topico_path(topico_created)) }
      it { should set_the_flash[:notice].to(notice) }
    end
  end

  describe '#suggest' do
    describe 'restricted to everyone' do
      before do
        get :suggest, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted to author' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :suggest, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be evaluated' do
      before do
        joining_topic_in_author_phase_and_user_like_coauthor
        get :suggest, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser avaliada') }
    end

    describe 'warning if suggestion are keeped blank' do
      before do
        joining_topic_in_pending_phase_and_user_like_coauthor
        put :suggest, :id => joining_topic.id
      end

      it { should set_the_flash[:warning].to('Você deve sugerir uma alteração') }
      it { should redirect_to(joining_topic_path(joining_topic)) }
    end

    describe 'change to author_phase and send email' do
      before do
        mailer = double
        mailer.should_receive(:deliver)
        JoiningTopicMailer.should_receive(:suggest).with(joining_topic.id, 'test').and_return(mailer)

        joining_topic_in_pending_phase_and_user_like_coauthor
        put :suggest, :id => joining_topic.id, :joining_topic => { :suggestion => 'test' }
        joining_topic.reload
      end

      it { joining_topic.author_phase?.should be_true }
      it { should set_the_flash[:notice].to('Suas sugestões foram enviadas para o autor') }
      it { should redirect_to(joining_topic_path(joining_topic)) }
    end
  end

  describe '#reject' do
    describe 'restricted to everyone' do
      before do
        get :reject, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted to author' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :reject, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be evaluated' do
      before do
        joining_topic_in_author_phase_and_user_like_coauthor
        get :reject, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser avaliada') }
    end

    describe 'save' do
      before do
        mailer = double
        mailer.should_receive(:deliver)
        JoiningTopicMailer.should_receive(:rejected).with(joining_topic.id).and_return(mailer)

        joining_topic_in_pending_phase_and_user_like_coauthor
        put :reject, :id => joining_topic.id
        joining_topic.reload
      end

      it { joining_topic.rejected_phase?.should be_true }
      it { should set_the_flash[:notice].to('Você rejeitou a união das suas propostas') }
      it { should redirect_to(joining_topic_path(joining_topic)) }
    end
  end

  describe '#aprove' do
    describe 'restricted to everyone' do
      before do
        get :aprove, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted to author' do
      before do
        joining_topic_in_pending_phase_and_user_like_author
        get :aprove, id: joining_topic.id
      end

      it { should redirect_to(root_path) }
      it { should set_the_flash[:warning].to('Você não pode acessar esta página') }
    end

    describe 'restricted if joining topic can not be evaluated' do
      before do
        joining_topic_in_author_phase_and_user_like_coauthor
        get :aprove, id: joining_topic.id
      end

      it { should redirect_to(joining_topic_path(joining_topic)) }
      it { should set_the_flash[:warning].to('A união não pode ser avaliada') }
    end

    describe 'save' do

      before do
        postman = double
        postman.should_receive(:deliver)
        AprovedJoiningTopicPostman.should_receive(:new).with(joining_topic).and_return(postman)

        joining_topic.topicos_from = [
          FactoryGirl.create(:competition_proposal_with_imagens_and_links),
          FactoryGirl.create(:competition_proposal_with_imagens_and_links)
        ]

        joining_topic_in_pending_phase_and_user_like_coauthor
        put :aprove, :id => joining_topic.id
        joining_topic.reload
      end

      it { joining_topic.aproved_phase?.should be_true }
      it { should set_the_flash[:notice].to('Você aceitou a união das suas propostas') }
      it { should redirect_to(joining_topic_path(joining_topic)) }

      describe 'created topico' do
        let(:author) { joining_topic.author }
        let(:topico_created) { Topico.last }

        describe 'type' do
          it { joining_topic.topico_to.should == topico_created }
        end

        describe 'general data' do
          it { topico_created.class.should == joining_topic.topico_to.class }
          it { topico_created.titulo.should == joining_topic.title }
          it { topico_created.descricao.should == joining_topic.description }
          it { topico_created.user.should == author }
          it { topico_created.competition.should == joining_topic.competition }
        end

        describe 'locais should be dupliated' do
          it { topico_created.locais.size.should == joining_topic.locais.size }
          it { topico_created.locais.last.should_not == joining_topic.locais.last }
          it { topico_created.locais.last.should == Local.last }
        end

        describe 'links should be dupliated' do
          it { topico_created.links.size.should == joining_topic.links.size }
          it { topico_created.links.last.should_not == joining_topic.links.last }
          it { topico_created.links.last.should == Link.last }
        end

        describe 'images should be dupliated' do
          it { topico_created.imagens.size.should == joining_topic.imagens.size }
          it { topico_created.imagens.last.should_not == joining_topic.imagens.last }
          it { topico_created.imagens.last.should == Imagem.last }
        end

        describe 'usuários que aderem' do
          it { topico_created.usuarios_que_aderem.size.should == joining_topic.usuarios_que_aderem.size }
        end

        describe 'tags' do
          it { topico_created.tags.size.should == joining_topic.tags.size }
          it { topico_created.owner_tags_on(author, :tags).size.should == joining_topic.tags.size }
        end
      end
    end
  end
end

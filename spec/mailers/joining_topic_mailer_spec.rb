require 'spec_helper'

describe JoiningTopicMailer do
  before do
    Settings['emails_administrador'] = "test@test.com"
  end

  describe '#created' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic) }

    subject { JoiningTopicMailer.created(joining_topic.id) }
    its(:subject) { should == "[Cidade Democrática] Uma nova sugestão de união foi deixada!" }
    its(:to) { should == [Settings['emails_administrador']] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }

    it { subject.body.encoded.should match(attribute_author_edit_admin_new_joining_topic_url(joining_topic)) }
  end

  describe '#attributed_author' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic_with_author) }
    let(:author) { joining_topic.author }

    subject { JoiningTopicMailer.attributed_author(joining_topic.id) }
    its(:subject) { should == "[Cidade Democrática] Sua proposta foi escolhida para ser unificada" }
    its(:to) { should == [author.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá #{author.nome}") }
    it { subject.body.encoded.should match("#{joining_topic.user.nome} sugeriu a união da sua proposta") }
    it { subject.body.encoded.should match("Com a proposta:\r\n#{joining_topic.coauthor_topico.titulo}") }
    it { subject.body.encoded.should match("dia #{I18n.l joining_topic.expiration_date}") }
    it { subject.body.encoded.should match(preview_joining_topic_url(joining_topic)) }
  end

  describe '#pending_phase' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic_with_author) }
    let(:author) { joining_topic.author }
    let(:coauthor) { joining_topic.coauthor }

    subject { JoiningTopicMailer.pending_phase(joining_topic.id) }
    its(:subject) { should == "[Cidade Democrática] Sua proposta foi escolhida para ser unificada" }
    its(:to) { should == [coauthor.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá #{coauthor.nome}") }
    it { subject.body.encoded.should match("#{joining_topic.user.nome} sugeriu a união da sua proposta") }
    it { subject.body.encoded.should match("Com a proposta:\r\n#{joining_topic.author_topico.titulo}") }
    it { subject.body.encoded.should match("dia #{I18n.l joining_topic.expiration_date}") }
    it { subject.body.encoded.should match(joining_topic_url(joining_topic)) }
  end

  describe '#suggest' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic_with_author) }
    let(:author) { joining_topic.author }
    let(:sugesstion) { Forgery(:basic).text }

    subject { JoiningTopicMailer.suggest(joining_topic.id, sugesstion) }
    its(:subject) { should == "[Cidade Democrática] O outro autor da sua união sugeriu mudanças" }
    its(:to) { should == [author.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá #{author.nome}") }
    it { subject.body.encoded.should match("sugeriu algumas mudanças") }
    it { subject.body.encoded.should match(sugesstion) }
    it { subject.body.encoded.should match("dia #{I18n.l joining_topic.expiration_date}") }
    it { subject.body.encoded.should match(preview_joining_topic_url(joining_topic)) }
  end

  describe '#rejected' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic_with_author) }
    let(:author) { joining_topic.author }
    before do
      joining_topic.title = Forgery(:basic).text
      joining_topic.save
    end

    subject { JoiningTopicMailer.rejected(joining_topic.id) }
    its(:subject) { should == "[Cidade Democrática] A união das propostas não foi aceita" }
    its(:to) { should == [author.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá #{author.nome}") }
    it { subject.body.encoded.should match(joining_topic.title) }
    it { subject.body.encoded.should match(joining_topic_url(joining_topic)) }
  end

  describe '#aproved_to_author' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic_aproved) }
    let(:author) { joining_topic.author }
    
    subject { JoiningTopicMailer.aproved_to_author(joining_topic.id) }
    its(:subject) { should == "[Cidade Democrática] A união das propostas foi aceita" }
    its(:to) { should == [author.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá #{author.nome}") }
    it { subject.body.encoded.should match(joining_topic.title) }
    it { subject.body.encoded.should match(joining_topic_url(joining_topic)) }
  end

  describe '#aproved_to_follower' do
    let(:joining_topic) { FactoryGirl.create(:joining_topic_aproved) }
    let(:author) { joining_topic.author }
    let(:user) { FactoryGirl.create(:user) }

    subject { JoiningTopicMailer.aproved_to_follower(joining_topic.id, user.id) }
    its(:subject) { should == "[Cidade Democrática] Uma proposta que você segue foi unificada" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá #{user.nome}") }
    it { subject.body.encoded.should match(joining_topic.title) }
    it { subject.body.encoded.should match(topico_url(joining_topic.topico_to)) }
  end
end

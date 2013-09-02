require 'spec_helper'

describe TopicoMailer do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:topico) { FactoryGirl.create(:proposta, user: user, titulo: 'Nova Proposta') }
  let!(:comment) { FactoryGirl.create(:comment, :user => user) }
  let!(:adesao) { FactoryGirl.create(:adesao, :user => user, :topico => topico) }

  before do
    User.stub(:find).and_return(user)
    Topico.stub(:find).and_return(topico)
    Comment.stub(:find).and_return(comment)
    Adesao.stub(:find).and_return(adesao)
  end

  describe '#new_comment' do
    subject { TopicoMailer.new_comment(1, 2, 3) }
    its(:subject) { should == "[Cidade Democrática] #{user.nome} comentou a proposta" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("#{user.nome} deixou o seguinte comentário na proposta \"Nova Proposta\"") }
    it { subject.body.encoded.should match(comment.body) }
  end

  describe '#nova_adesao' do
    subject { TopicoMailer.nova_adesao(1, 2) }
    its(:subject) { should == "[Cidade Democrática] #{user.nome} apoiou a proposta no Cidade Democrática!" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("#{user.nome} apoiou a proposta \"Nova Proposta\"") }
  end

  describe '#remove_adesao' do
    subject { TopicoMailer.remove_adesao(1, 2) }
    its(:subject) { should == "[Cidade Democrática] #{user.nome} removeu o apoio de uma proposta no Cidade Democrática!" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("#{user.nome} deixou de apoiar a proposta \"Nova Proposta\"") }
  end

  describe '#envia_seguidor' do
    subject { TopicoMailer.envia_seguidor(1, "apoiou", 2, "Adesao", 3) }
    its(:subject) { should == "[Cidade Democrática] Nova atividade de uma proposta no Cidade Democrática!" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    its(:reply_to) { should be_nil }
    it { subject.body.encoded.should match("#{user.nome} apoiou a proposta \"Nova Proposta\"") }
  end
end

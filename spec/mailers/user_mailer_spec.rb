require 'spec_helper'

describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }

  before do
    User.stub(:find).and_return(user)
    user.stub(:id_criptografado).and_return("12345")
  end

  describe '#solicitar_vinculacao' do
    subject { UserMailer.solicitar_vinculacao(user.id, user.id) }
    its(:subject) { should == "[Cidade Democrática] #{user.nome} quer fazer parte de #{user.nome}" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match(user.id_criptografado) }
  end

  describe '#observatorio' do
    before do
      user.stub_chain(:observatorios, :first).and_return(FactoryGirl.create(:observatorio, :user => user))
      user.stub_chain(:observatorios, :first, :atividades).and_return([FactoryGirl.create(:proposta, :user => user)])
    end
    subject { UserMailer.observatorio(user.id) }
    its(:subject) { should == "[Cidade Democrática] Resumo do observatório" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match("Olá, #{user.nome}!")}
    it { subject.body.encoded.should match("aconteceu 1 atividade em tópicos de seu interesse")}
    it { subject.body.encoded.should match("1 Proposta/problema que usuários cadastraram")}
  end

  describe '#contato' do
    subject { UserMailer.contato(user.id, {"nome" => "foo", "email" => "foo@foo.com", "mensagem" => "Hello World"}) }
    its(:subject) { should == "[Cidade Democrática] Nova mensagem de Foo" }
    its(:to) { should == [user.email] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    its(:reply_to) { should == ["foo@foo.com"] }
    it { subject.body.encoded.should match("Olá #{user.nome}")}
    it { subject.body.encoded.should match(/Foo \(foo@foo.com\) visitou seu perfil/)}
    it { subject.body.encoded.should match("Hello World")}
  end
end

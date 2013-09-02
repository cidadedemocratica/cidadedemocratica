require 'spec_helper'

describe AdminMailer do
  let(:solicitante) { { :nome => "Fulano", :email => "fulano@foo.com", :entidade => "Acme Inc.", :type => "cidadao"} }
  let(:denuncia) { { :nome => "Fulano", :email => "fulano@foo.com", :descricao => "hello world"} }
  let(:topico) { FactoryGirl.build(:proposta, titulo: 'Nova Proposta') }

  describe '#pedido_cadastro_entidade' do
    subject { AdminMailer.pedido_cadastro_entidade(solicitante) }
    its(:subject) { should == '[Cidade Democrática] Fulano solicitou um cadastro de "Acme Inc." no Cidade Democrática!' }
    its(:to) { should == ["ryband@uol.com.br"] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match('Fulano, com o email "fulano@foo.com"') }
    it { subject.body.encoded.should match('para a entidade "Acme Inc." como  "cidadao"') }
  end

  describe '#denuncia_em_topico' do
    before { Topico.stub(:find).and_return(topico) }
    subject { AdminMailer.denuncia_em_topico(topico.id, denuncia) }
    its(:subject) { should == '[Cidade Democrática] Fulano denunciou algo em "Nova Proposta" no Cidade Democrática!' }
    its(:to) { should == ["ryband@uol.com.br"] }
    its(:from) { should == ["noreply@cidadedemocratica.org.br"] }
    it { subject.body.encoded.should match('Fulano, com o email fulano@foo.com,') }
    it { subject.body.encoded.should match('denunciou o tópico "Nova Proposta"') }
    it { subject.body.encoded.should match('hello world') }
  end
end


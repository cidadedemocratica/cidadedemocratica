require 'spec_helper'

describe TopicoMetaTags do
  let!(:topic) { FactoryGirl.create(:proposta) }

  describe 'meta tags' do
    subject { TopicoMetaTags.new(test_request, topic).generate }
    it { subject[:keywords].should == topic.keywords }
  end

  describe 'open graph tags' do
    subject { TopicoMetaTags.new(test_request, topic).generate }
    it { subject[:og][:title].should == "#{topic.display_name}: #{topic.titulo}" }
    it { subject[:og][:description].should == topic.descricao }
    it { subject[:og][:type].should == "cause" }
    it { subject[:og][:image].should == "http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs468.snc4/49311_100001089376554_6583_n.jpg" }
  end
end

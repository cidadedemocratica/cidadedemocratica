require 'spec_helper'

describe DefaultMetaTags do
  before do
    Settings.should_receive(:head_description).any_number_of_times.and_return("description")
    Settings.should_receive(:head_keywords).any_number_of_times.and_return("keywords")
  end

  describe 'meta tags' do
    subject { DefaultMetaTags.new(test_request).generate }
    it { subject[:description].should == "description" }
    it { subject[:keywords].should == "keywords" }
  end

  describe 'open graph tags' do
    subject { DefaultMetaTags.new(test_request).generate }
    it { subject[:og][:site_name].should == "Cidade Democrática" }
    it { subject[:og][:type].should == "cause" }
    it { subject[:og][:description].should == "description" }
    it { subject[:og][:url].should == test_request.protocol + test_request.host_with_port + test_request.fullpath }
    it { subject[:og][:image].should == "http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs468.snc4/49311_100001089376554_6583_n.jpg" }
  end
end

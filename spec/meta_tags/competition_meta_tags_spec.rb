require 'spec_helper'

describe CompetitionMetaTags do
  let!(:competition) { FactoryGirl.create(:competition) }
  before do
    competition.stub_chain(:image, :url).and_return "blah"
  end

  describe 'meta tags' do

  end

  describe 'open graph tags' do
    subject { CompetitionMetaTags.new(test_request, competition).generate }
    it { subject[:og][:title].should == "Concurso: #{competition.title}" }
    it { subject[:og][:description].should == competition.short_description }
    it { subject[:og][:type].should == "cause" }
    it { subject[:og][:image].should == test_request.protocol + test_request.host_with_port + competition.image.url(:small) }
  end
end

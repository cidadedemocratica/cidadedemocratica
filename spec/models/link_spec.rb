require 'spec_helper'

describe Link do
  describe 'validations' do
    it { should validate_presence_of(:nome) }
    it 'invalid url' do
      link = Link.create(:nome => Forgery(:basic).text, :url => 'http://www')
      link.should_not be_valid
    end
    it 'valid url' do
      link = Link.create(:nome => Forgery(:basic).text, :url => 'http://www.codeminer42.com')
      link.should be_valid
    end
  end
end

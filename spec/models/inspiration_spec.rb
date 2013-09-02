require 'spec_helper'

describe Inspiration do
  describe 'associations' do
    it { should belong_to(:competition) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:image) }
  end
end

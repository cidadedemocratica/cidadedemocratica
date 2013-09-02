require 'spec_helper'

describe CompetitionPrize do
  context 'associations' do
    it { should belong_to(:competition) }
    it { should belong_to(:offerer).class_name('User') }
    it { should belong_to(:winning_topic).class_name('Topico') }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:competition_id) }
    it { should validate_presence_of(:offerer) }
  end
end

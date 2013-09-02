FactoryGirl.define do
  factory :competition_prize, :class => 'CompetitionPrize' do
    name Forgery(:basic).text
    description Forgery(:basic).text
    offerer { FactoryGirl.create(:user) }
  end
end

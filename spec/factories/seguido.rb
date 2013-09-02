FactoryGirl.define do
  factory :seguido do
    user
    topico { FactoryGirl.create(:proposta) }
  end
end

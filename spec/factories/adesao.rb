FactoryGirl.define do
  factory :adesao do
    user
    topico { FactoryGirl.create(:proposta) }
  end
end

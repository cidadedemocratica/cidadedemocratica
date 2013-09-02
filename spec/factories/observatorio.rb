FactoryGirl.define do
  factory :observatorio do
    user
    nome { |u| u.user.nome }
  end
end

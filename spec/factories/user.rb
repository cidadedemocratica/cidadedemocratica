FactoryGirl.define do
  factory :user_dado do
    nome { Forgery(:name).full_name }
    sexo 'm'
    aniversario Time.now.to_date
    descricao { Forgery(:basic).text }
  end

  factory :user do
    password { Forgery(:basic).password(at_least: 8) }
    password_confirmation { "#{password}" }
    sequence :email do |n|
      "test#{n}@example.com"
    end

    after(:create) do |user|
      FactoryGirl.create(:user_dado, user: user)
      user.confirm!
      user.activate!
    end

    factory :admin, class: Admin do
    end

    factory :cidadao, class: Cidadao do
    end
  end
end


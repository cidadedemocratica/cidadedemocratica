# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :macro_tag do
    title Forgery(:basic).text
  end
end

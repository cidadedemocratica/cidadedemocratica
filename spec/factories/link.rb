FactoryGirl.define do
  factory :link do
    nome { Forgery(:basic).text }
    url { "http://#{Forgery(:basic).text}.com" }
  end
end

FactoryGirl.define do
  factory :comment do
    body { Forgery(:basic).text }
    tipo 'comentario'
    user
  end
end

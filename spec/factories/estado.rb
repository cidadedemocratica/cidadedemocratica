FactoryGirl.define do
  factory :estado do
    nome "Sao Paulo"
    abrev "SP"
  end

  factory :estado_sp, class: Estado do
    id 1
    nome 'São Paulo'
    abrev  'SP'
  end

  factory :estado_mg, class: Estado do
    id  2
    nome  'Minas Gerais'
    abrev  'MG'
  end
end

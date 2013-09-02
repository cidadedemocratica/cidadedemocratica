FactoryGirl.define do
  factory :bairro do
    nome "Campo Belo"
    cidade
  end

  factory :bairro_sp_sao_paulo_vila_pompeia, class: Bairro do
    id 3585
    nome 'Vila Pompéia'
    cidade_id 1
  end

  factory :bairro_sp_sao_paulo_parque_novo_grajau, class: Bairro do
    id 3000
    nome "Parque Novo Grajaú"
    cidade_id 1
  end
end

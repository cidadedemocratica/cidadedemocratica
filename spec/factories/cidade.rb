FactoryGirl.define do
  factory :cidade do
    nome "Sao Paulo"
    slug "sao-paulo"
    estado
  end

  factory :cidade_sp_sao_paulo, class: Cidade do
    id 1
    nome 'São Paulo'
    estado_id 1
  end

  factory :cidade_sp_campinas, class: Cidade do
    id 2
    nome 'Campinas'
    estado_id 1
  end

  factory :cidade_mg_abatae, class: Cidade do
    id 2593
    nome 'Abaeté'
    estado_id 2
  end

  factory :cidade_mg_abadia_dos_dourados, class: Cidade do
    id 2592
    nome 'Abadia dos Dourados'
    estado_id 2
  end
end

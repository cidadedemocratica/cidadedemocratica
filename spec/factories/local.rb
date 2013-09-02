FactoryGirl.define do
  factory :local do
    bairro
    cidade { |u| u.bairro.cidade }
    estado { |u| u.cidade.estado }
    pais_id { FactoryGirl.find_or_create_by_id(:pais_br).id }
    cep "04610-004"
  end

  factory :local_nacional, :class => Local do
    pais_id { FactoryGirl.find_or_create_by_id(:pais_br).id }
  end
end

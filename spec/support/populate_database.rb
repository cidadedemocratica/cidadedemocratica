def create_locations
  FactoryGirl.find_or_create_by_id(:pais_br)

  FactoryGirl.find_or_create_by_id(:estado_sp)
  FactoryGirl.find_or_create_by_id(:estado_mg)

  FactoryGirl.find_or_create_by_id(:cidade_sp_sao_paulo)
  FactoryGirl.find_or_create_by_id(:cidade_sp_campinas)

  FactoryGirl.find_or_create_by_id(:cidade_mg_abatae)
  FactoryGirl.find_or_create_by_id(:cidade_mg_abadia_dos_dourados)

  FactoryGirl.find_or_create_by_id(:bairro_sp_sao_paulo_vila_pompeia)
  FactoryGirl.find_or_create_by_id(:bairro_sp_sao_paulo_parque_novo_grajau)
end

FactoryGirl.define do
  factory :proposta do
    titulo { Forgery(:basic).text }
    descricao { Forgery(:basic).text }
    tags_com_virgula 'tag1, tag2'
    locais { [ FactoryGirl.create(:local) ] }
    user

    after(:create) do |proposta|
      proposta.user.tag proposta, :with => proposta.tags_com_virgula, :on => :tags
    end

    factory :proposta_with_imagens_and_links do
      after(:create) do |proposta|
        FactoryGirl.create(:link, topico: proposta)
        FactoryGirl.create(:imagem, responsavel: proposta)
      end
    end
  end

  factory :proposta_com_ambito_nacional, :parent => :proposta do
    locais { [ FactoryGirl.create(:local_nacional) ] }
  end
end

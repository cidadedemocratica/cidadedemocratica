FactoryGirl.define do
  factory :imagem do
    legenda { Forgery(:basic).text }
    uploaded_data { fixture_file_upload('./spec/fixture_file/image.jpg', 'image/jpg') }
  end
end

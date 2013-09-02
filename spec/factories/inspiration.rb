FactoryGirl.define do
  factory :inspiration do
    title Forgery(:basic).text
    description Forgery(:basic).text
    image { fixture_file_upload('./spec/fixture_file/image.jpg', 'image/jpg') }
    user
  end
end

FactoryGirl.define do
  factory :competition do
    title Forgery(:basic).text
    short_description Forgery(:basic).text
    long_description Forgery(:basic).text
    author_description Forgery(:basic).text
    regulation Forgery(:basic).text
    awards Forgery(:basic).text
    start_date Time.now
    inspiration_phase 10
    proposals_phase 10
    support_phase 10
    joining_phase 10
    announce_phase 10
    published true
    image { fixture_file_upload('./spec/fixture_file/image.jpg', 'image/jpg') }
  end

  factory :competition_in_inspiration_phase, :parent => :competition do
    start_date 60.days.ago.to_date
    inspiration_phase 100
    current_phase :inspiration_phase
  end

  factory :competition_in_proposals_phase, :parent => :competition do
    start_date 60.days.ago.to_date
    proposals_phase 100
    current_phase :proposals_phase
  end

  factory :competition_in_support_phase, :parent => :competition do
    start_date 60.days.ago.to_date
    support_phase 100
    current_phase :support_phase
  end

  factory :competition_in_joining_phase, :parent => :competition do
    start_date 60.days.ago.to_date
    joining_phase 100
    current_phase :joining_phase
  end

  factory :competition_in_announce_phase, :parent => :competition do
    start_date 60.days.ago.to_date
    announce_phase 100
    current_phase :announce_phase
  end
end

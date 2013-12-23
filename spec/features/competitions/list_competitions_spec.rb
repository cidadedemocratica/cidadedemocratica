require 'spec_helper'

feature 'List Competitions' do
  scenario 'Running Competitions' do
    competition = FactoryGirl.create(:competition_in_inspiration_phase)

    visit competitions_path

    page.should have_content competition.title
  end

  scenario 'Finished Competitions' do
    finished_competition =
      FactoryGirl.create(:competition_in_inspiration_phase,
        :title => 'Finished Competition', :finished => true)
    running_competition = FactoryGirl.create(:competition_in_proposals_phase)

    visit competitions_path

    page.should have_content finished_competition.title
    page.should have_content running_competition.title
  end

  scenario 'Unpublished Competitions' do
    unpublished_competition =
      FactoryGirl.create(:competition_in_inspiration_phase, :published => false)

    visit competitions_path

    page.should_not have_content unpublished_competition.title
  end
end

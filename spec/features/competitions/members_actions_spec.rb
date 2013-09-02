require 'spec_helper'

feature 'Members actions' do
  let!(:competition) { FactoryGirl.create(:competition_in_inspiration_phase) }

  scenario 'regulation' do
    visit regulation_competition_path(competition)
    page.should have_content 'Regulamento'
  end

  scenario 'awards' do
    visit prizes_competition_path(competition)
    page.should have_content 'Prêmios'
  end

  scenario 'partners' do
    visit partners_competition_path(competition)
    page.should have_content 'Parceiros'
  end
end

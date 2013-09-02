require 'spec_helper'

feature 'Suggest Join' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:competition_in_joining_phase) { FactoryGirl.create(:competition_in_joining_phase) }
  let!(:topic) { FactoryGirl.create(:competition_proposal, :id => 1, :competition_id => competition_in_joining_phase.id) }
  let!(:related_topic) { FactoryGirl.create(:competition_proposal, :id => 2, :competition_id => competition_in_joining_phase.id) }

  before do
    sign_in user
  end

  scenario 'can be joined' do
    visit topico_path(topic)

    click_link('Sugira uma União')

    within('#new_joining_topic') do
      click_button('Unir a esta proposta')
    end

    page.should have_content 'Sua sugestão de união foi cadastrada com sucesso'
  end
end

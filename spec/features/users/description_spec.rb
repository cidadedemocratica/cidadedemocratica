require 'spec_helper'

feature 'User profile', :js => true do
  let!(:user) { FactoryGirl.create(:user) }

  scenario 'shows description' do
    visit perfil_path(user)

    page.should_not have_content('ainda não escreveu uma descrição')
    page.should have_content(user.descricao)
  end
end

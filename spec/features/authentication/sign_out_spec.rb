require 'spec_helper'

feature 'Sign out', :js => true do
  let!(:user) { FactoryGirl.create(:user) }

  scenario 'always works' do
    sign_in user

    sign_out

    page.should have_content('Saiu com sucesso.')
  end
end

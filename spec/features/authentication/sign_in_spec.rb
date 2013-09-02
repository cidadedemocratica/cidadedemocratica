require 'spec_helper'

feature 'Sign in', :js => true do
  let!(:user) { FactoryGirl.create(:user) }

  scenario 'with valid credentials' do
    sign_in user

    page.should have_content('Login efetuado com sucesso!')
  end

  scenario 'with invalid credentials' do
    sign_in user, password: 'wrongpassword'

    page.should have_content('E-mail ou senha inválidos.')
  end
end

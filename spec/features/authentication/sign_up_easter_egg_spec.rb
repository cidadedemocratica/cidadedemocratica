require 'spec_helper'

feature 'Sign up', :js => true do
  background do
    create_locations
  end

  scenario 'with valid credentials creates an easter egg on waiting for confirmation page with the confirmation link to be used on the ocasion of events, so the user can start using the website faster' do
    visit new_user_registration_path

    fill_in 'cad_user_email', with: 'user_email@example.com'

    fill_in 'cad_user_pass', with: 'password'
    fill_in 'user_password_confirmation', with: 'password'

    click_button 'Cadastrar'
    page.should have_content('Falta pouco para você participar do Cidade Democrática...')

    click_link '!'

    fill_in 'Nome', with: 'Nome do usuario'
    select 'Vila Pompéia'

    click_button 'Salvar'
    page.should have_content('Pronto!')
    page.should have_content('Olá, Nome!')
  end
end

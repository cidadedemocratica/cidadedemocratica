require 'spec_helper'

feature 'Redirect after sign in', :js => true do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:proposal) { FactoryGirl.create(:proposta) }

  scenario 'User is commenting' do
    visit topico_path(proposal)

    click_link 'Comente'
    fill_in 'comment_body', with: 'Texto do comentario'
    click_button 'Publicar'

    page.should have_content('Para continuar, efetue login ou registre-se.')

    sign_in user, :visit => false

    page.should have_content('Comentário criado com sucesso.')
  end
end

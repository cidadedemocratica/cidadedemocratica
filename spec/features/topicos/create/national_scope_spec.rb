require 'spec_helper'

feature 'Create proposals', :js => true do
  let!(:user) { FactoryGirl.create(:user) }

  background do
    create_locations
    sign_in user
  end

  scenario 'in national scope' do
    visit novo_topico_path(type: 'proposta')

    # basic data
    fill_in 'topico_titulo', with: 'titulo do topico'
    fill_in 'topico_descricao', with: 'descricao'
    fill_in 'topico_tags_com_virgula', with: 'tag1, tag2'
    click_button 'Continuar'

    # location
    click_link 'Nacional'
    find('#seletor_de_pais input#bot_continuar').click

    # done
    page.should have_content('proposta cadastrada com sucesso')
    all('p.local a', text: 'Todo o país').count.should == 1
    all('p.tags a', text: 'tag').count.should == 2
  end
end

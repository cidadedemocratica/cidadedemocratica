require 'spec_helper'

feature 'Change proposal location', :js => true do
  let!(:admin) { FactoryGirl.create(:admin) }
  let!(:proposal) { FactoryGirl.create(:proposta) }

  background do
    sign_in admin
  end

  scenario 'as admin' do
    visit topico_path(proposal)

    find('p.local a.edit_lnk').click

    click_link 'Municipal'
    find('#seletor_de_cidades input#bot_continuar').click
    all('p.local a').count
    all('p.local a', text: 'Sao Paulo - SP').count.should == 1
  end

  scenario 'with comments' do
    FactoryGirl.create(:comment, commentable: proposal)

    visit topico_path(proposal)

    find('p.local a.edit_lnk').click
    click_link 'Municipal'
    find('#seletor_de_cidades input#bot_continuar').click
    all('p.local a').count
    all('p.local a', text: 'Sao Paulo - SP').count.should == 1
  end
end

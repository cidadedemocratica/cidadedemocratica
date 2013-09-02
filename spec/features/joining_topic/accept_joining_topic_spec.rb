require "spec_helper"

feature "Accept Joining Topic" do
  given!(:joining_topic) { FactoryGirl.create(:joining_topic_pending) }
  given!(:coauthor) { joining_topic.coauthor }

  background do
    sign_in coauthor
  end

  scenario "accepts" do
    visit joining_topic_path(joining_topic)

    page.should have_content "Veja os novos títulos, descrição, lista de territórios e palavras-chave."

    click_button "Aceitar união"

    page.should have_content "Você aceitou a união das suas propostas"
  end
end

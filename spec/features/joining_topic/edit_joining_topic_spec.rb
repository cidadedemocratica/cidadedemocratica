require "spec_helper"

feature "Edit Joining Topic" do
  given!(:joining_topic) { FactoryGirl.create(:joining_topic_with_author) }
  given!(:author) { joining_topic.author }
  given!(:topic_one) { joining_topic.topicos_from.first }
  given!(:topic_two) { joining_topic.topicos_from.last }

  background do
    sign_in author
  end

  scenario "authors complete joining topic creation" do
    visit preview_joining_topic_path(joining_topic)

    page.should have_content topic_one.titulo
    page.should have_content topic_two.titulo

    click_link "Continuar"

    current_path.should eq title_edit_joining_topic_path(joining_topic)

    within("#edit_joining_topic_#{joining_topic.id}") do
      fill_in "joining_topic[title]", :with => "New Title"
      click_button "Continuar"
    end

    current_path.should eq description_edit_joining_topic_path(joining_topic)

    within("#edit_joining_topic_#{joining_topic.id}") do
      fill_in "joining_topic[description]", :with => "New Description"
      click_button "Enviar nova proposta"
    end

    page.should have_content "Proposta enviada para avaliação do co-autor"
    current_path.should eq joining_topic_path(joining_topic)
  end
end

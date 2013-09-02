# encoding: utf-8

require 'spec_helper'

feature 'Show competition' do
  scenario 'all phases enabled' do
    competition = FactoryGirl.create(:competition_in_inspiration_phase)
    visit competition_path(competition.id)

    phases = find('.competition_phase').all('li')
    phases.count.should eq Competition::PHASES.count
  end

  scenario 'phase desabled' do
    competition =
      FactoryGirl.create(:competition_in_inspiration_phase, :joining_phase => 0)
    visit competition_path(competition.id)

    phases = find('.competition_phase').all('li').map(&:text)
    phases.should_not include('União')
  end

  scenario 'current phase' do
    competition = FactoryGirl.create(:competition_in_inspiration_phase)
    visit competition_path(competition)

    active_phase = find('.competition_phase li.active')
    active_phase.text.should eq 'Inspiração'
  end

  scenario 'specific phase' do
    competition = FactoryGirl.create(:competition_in_announce_phase)

    visit competition_path(competition, :phase => :proposals_phase)

    active_phase = find('.competition_phase li.active')
    active_phase.text.should eq 'Propostas'
  end

  scenario 'specific phase with order' do
    competition = FactoryGirl.create(:competition_in_proposals_phase)
    visit competition_path(competition, :phase => :proposals_phase,
      :order => 'relevancia')

    selected_order = find('#ordenador a.selected')
    selected_order.text.should eq 'Relevância'
  end

  scenario 'specific phase with tags' do
    competition = FactoryGirl.create(:competition_in_proposals_phase)
    proposta    = FactoryGirl.create(:proposta, :competition => competition)
    tag = proposta.tags.first

    visit competition_path(competition, :phase => :proposals_phase,
      :tag_id => tag.id)

    breadcrumb = find('#breadcrumb')
    breadcrumb.should have_content(tag.name)
  end

  scenario 'future phase' do
    competition = FactoryGirl.create(:competition_in_inspiration_phase)

    visit competition_path(competition, :phase => :proposals_phase)
    active_phase = find('.competition_phase li.active')
    active_phase.text.should eq 'Inspiração'
  end

  scenario 'unpublished' do
    competition = FactoryGirl.create(:competition_in_inspiration_phase, :published => false)

    visit competition_path(competition)

    page.should have_content 'Este concurso não está publicado'
  end
end

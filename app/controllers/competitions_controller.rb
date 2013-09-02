class CompetitionsController < ApplicationController
  respond_to :html

  inherit_resources

  with_options :cache_path => Proc.new { |c| { :params => c.params, :flash => c.flash.to_hash } }, :layout => false, :if => Proc.new { current_user.nil? || !current_user.admin? } do |c|

    c.with_options :expires_in => 2.minutes do |c|
      c.caches_action :index
    end

    c.with_options :expires_in => 5.minutes do |c|
      c.caches_action :regulation
      c.caches_action :prizes
      c.caches_action :partners
    end
  end

  before_filter :set_competition_meta_tags, :except => :index
  before_filter :redirect_unpublished, :only => :show

  def index
    @running_competitions  = Competition.running.includes(:locais)
    @finished_competitions = Competition.finished.includes(:locais)
  end

  def regulation
  end

  def prizes
    @prizes = resource.prizes
  end

  def partners
  end

  def show
    @phase = params[:phase].try(:to_sym) || resource.current_phase
    if resource.future_phase?(@phase)
      redirect_to competition_path(resource)
    else
      case @phase
        when :inspiration_phase
          phase_with_inspirations
        when :announce_phase
          phase_with_prizes
        else
          phase_with_proposals
      end
      @activities = resource.activities_summary
      render @phase
    end
  end

  protected

  def set_competition_meta_tags
    set_meta_tags CompetitionMetaTags.for(request, resource)
  end

  def redirect_unpublished
    redirect_to(competitions_path, :alert => "Este concurso não está publicado") unless resource.published?
  end

  def phase_with_inspirations
    @inspirations = resource.inspirations.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
  end

  def phase_with_prizes
    @prizes = resource.prizes_with_defined_winning_topic
  end

  def phase_with_proposals
    @tag = Tag.find(params[:tag_id]) unless params[:tag_id].blank?

    @proposals = resource.proposals.includes(:user)
    proposals_order
    proposals_tags
    proposals_paginate
  end

  def proposals_order
    @proposals = case params[:order]
      when "recentes"
        @proposals.order("topicos.created_at DESC")
      when "mais_comentarios"
        @proposals.order("topicos.comments_count DESC")
      when "mais_apoios"
        @proposals.order("topicos.adesoes_count DESC")
      else
        params[:order] = "relevancia"
        @proposals.order("topicos.relevancia DESC")
    end
  end

  def proposals_tags
    @proposals = @proposals.maybe_tagged_with(@tag)
    @tags = @proposals.tags_to_cloud
  end

  def proposals_paginate
    @proposals = @proposals.paginate(:page => params[:page], :per_page => 10)
  end

  def collection
    @competitions ||= end_of_association_chain.running
  end
end

class HomeController < ApplicationController
  before_filter :redirect_domains_to_competition, :only => [ :index ]
  caches_action :index, :expires_in => 5.minutes

  def redirect_domains_to_competition
    competition = Competition::DOMAINS.find do |domain, data|
      request.host.include? domain
    end
    if competition
      resource = Competition.find(competition.last[:id])
      redirect_to "http://www.cidadedemocratica.org.br#{competition_path(resource)}"
    end
  end

  def index
    @running_competitions  = Competition.running.includes(:locais)
    @finished_competitions = Competition.finished.includes(:locais)
    @tags = Topico.random_tags_to_cloud[0..20]
    @activities = ActivitiesBase.new.activities_summary

    @counters = {
      :topics => Topico.count,
      :activities => Comment.by_topic.count + Adesao.count + Seguido.count,
      :users => User.ativos.nao_admin.count
    }
  end

  # Lista de todas as tags do site
  def temas
    @starts_with = params[:starts_with].blank? ? "a" : params[:starts_with]
    @links = ActsAsTaggableOn::Tag.select("substring(name,1,1) as letra").group("letra").order("letra").all.map(&:letra)
    @tags = ActsAsTaggableOn::Tag.select("tags.id as id, tags.name as name, count(taggings.id) as taggings_count").
      joins(:taggings).
      where("tags.name like ?", "#{@starts_with}%").
      group("tags.id").
      paginate(:order => "taggings_count DESC", :page => params[:page])
  end
end

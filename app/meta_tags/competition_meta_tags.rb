class CompetitionMetaTags < DefaultMetaTags
  attr_accessor :competition

  def initialize(request, competition)
    self.competition = competition
    super
  end

  def generate
    super.deep_merge(
      :og => {
        :title => "Concurso: #{competition.title}",
        :description => competition.short_description,
        :image => request.protocol + request.host_with_port + competition.image.url(:small)
      }
    )
  end
end

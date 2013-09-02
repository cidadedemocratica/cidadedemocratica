class TopicoMetaTags < DefaultMetaTags
  attr_accessor :topico

  def initialize(request, topico)
    self.topico = topico
    super
  end

  def generate
    super.deep_merge(
      :keywords => topico.keywords,
      :og => {
        :title => "#{topico.display_name}: #{topico.titulo}",
        :description => "#{topico.descricao}"
      }
    )
  end
end

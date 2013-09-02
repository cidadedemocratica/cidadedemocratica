class GeneralReportActivities < GeneralReportBase
  def initialize(from, to)
    dates_with_zero = (from..to).each_with_object({}) do |date, hash|
      hash[date.strftime("%Y-%m-%d")] = 0
    end
    @store = (
      %w(topicos comments adesoes seguidos total) +
      %w(propostas problemas) +
      %w(comment_comentarios comment_ideias comment_perguntas comment_respostas)
    ).each_with_object({}) do |kind, hash|
      hash[kind] = dates_with_zero.dup
    end
  end

  def add(name, model)
    date = model.created_at.strftime("%Y-%m-%d")
    @store["total"][date] += 1
    @store[name][date] += 1
    if name == "topicos"
      @store[model.type.pluralize.downcase][date] += 1
    end
    if name == "comments"
      @store["comment_" + model.tipo.pluralize][date] += 1
    end
  end

  def data
    @store
  end

  def stats
    Hash[@store.map { |k, v| [k, v.map(&:last).reduce(:+)] } ]
  end
end

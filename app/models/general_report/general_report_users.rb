class GeneralReportUsers < GeneralReportBase
  def add(name, model)
    @store[model.user_id]["model"] ||= model.user
    @store[model.user_id]["total"] += 1
    @store[model.user_id][name + "_count"] += 1
    if name == "topicos"
      @store[model.user_id][model.type.pluralize.downcase + "_count"] += 1
    end
  end

  def relevance!
    calculate_relevance = CalculateRelevance.new(User::COUNTERS_TO_RELEVANCE)
    @store.each do |id, counters|
      @store[id] = calculate_relevance.for_counters(counters)
    end
  end

  def data
    @store.sort_by { |id, data| data["relevancia"] }.reverse
  end

  def data_by_group
    data.group_by { |id, data| data["model"].nome_do_tipo }.map do |type, group|
      [type, group[0..2].map { |id, value| value }]
    end
  end
end

class GeneralReportLocals < GeneralReportBase
  def initialize(local_scoped)
    super()
    @local_scoped = local_scoped
  end

  def add(name, model)
    topic_model(model).locais.map(&@local_scoped[:field]).uniq.each do |local_id|
      @store[local_id]["total"] += 1
      @store[local_id]["users"] << model.user
      @store[local_id][name + "_count"] += 1
      count_activities_and_types_of_topics(name, local_id, model)
    end
  end

  def data
    @store.sort_by { |k,v| v["total"] }.reverse[0..9].map do |local, data|
      data["users"].uniq!
      data["users_stats"] = users_stats(data["users"])
      local = (local ? @local_scoped[:model].find(local).nome : "Não definido") unless local == "all"
      [local , data]
    end
  end

  private

  def count_activities_and_types_of_topics(name, local_id, model)
    if name == "topicos"
      @store[local_id][model.type.pluralize.downcase + "_count"] += 1
    end
  end
end

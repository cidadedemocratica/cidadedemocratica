class GeneralReportTopics < GeneralReportBase
  def add(name, model, topic = nil)
    topic = topic_model(model) if topic.nil?
    @store[topic.id]["model"] ||= topic
    @store[topic.id]["users"] << model.user

    add_joining_comments(name, model, topic)
    count_activities(name, model, topic)
  end

  def relevance!
    calculate_relevance = CalculateRelevance.new(Topico::COUNTERS_TO_RELEVANCE)
    @store.each do |id, counters|
      @store[id] = calculate_relevance.for_counters(counters)
    end
  end

  def data
    data = @store.sort_by { |id, data| data["relevancia"] }.reverse
    data = data.group_by { |id, data| data["model"].type }
    data.map do |type, group|
      [type, group[0..9].map do |id, data|
        data["users"].uniq!
        data["users_stats"] = users_stats(data["users"])
        data
      end]
    end
  end

  def users_grouped
    @store.map do |id, data|
      data["users"].map(&:nome)
    end
  end

  private

  def add_joining_comments(name, model, topic)
    if name == "comments" and topic.joining.present?
      topic_to = topic.joining.topico_to
      add(name, model, topic_to) if topic_to != topic
    end
  end

  def count_activities(name, model, topic)
    if name != "topicos"
      @store[topic.id][name + "_count"] += 1
      @store[topic.id]["total"] += 1
    end
  end
end

class GeneralReportWords < GeneralReportBase
  def initialize
    @words = ""
  end

  def add_collection(collection, attributes)
    attributes = [attributes] unless attributes.kind_of? Array
    attributes.each do |attribute|
      @words += collection.map(&attribute.to_sym).reduce("", :+)
    end
  end

  def clear_and_group_count
    data = @words.downcase.gsub(/[.,;:?!()|*"']/, "").
      split(/\s+/).map(&:singularize).group_by(&:to_s)
    exclude_words_from_group(data).map { |k, v| [k, v.count] }
  end

  def exclude_words_from_group(data)
    exclude_words = Settings['relatorios_termos_excluidos'].split(",")
    data.reject { |w, ws| ws.count < 4 or w.size < 4 or exclude_words.include?(w) }
  end

  def count
    Hash[clear_and_group_count.sort_by(&:last).reverse]
  end
end

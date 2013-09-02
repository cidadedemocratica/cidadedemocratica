class CalculateRelevance

  def initialize(formula)
    @formula = formula
  end

  def for_counters(counters)
    relevancia = counters.collect do |counter, value|
      method = @formula.fetch(counter) rescue (next 0)
      settings(method) * value * 100
    end.reduce(&:+)
    counters.merge "relevancia" => relevancia
  end

  def self.for_counters(counters, formula)
    self.new(formula).for_counters(counters)
  end

  protected

  def settings(method)
    @settings = {} unless @settings
    unless @settings.has_key? method
      @settings[method] = Settings.send(method).to_f
    end
    @settings[method]
  end
end

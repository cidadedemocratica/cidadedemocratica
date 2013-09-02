class FindOrCreateByIdStrategy
  def initialize
    @strategy = FactoryGirl.strategy_by_name(:create).new
  end

  def association(runner)
    runner.run
  end

  def result(evaluation)
    existing = evaluation.object.class.find_by_id(evaluation.object.id)
    existing || @strategy.result(evaluation)
  end
end

FactoryGirl.register_strategy(:find_or_create_by_id, FindOrCreateByIdStrategy)

require_relative '../../../lib/services/calculate_relevance'

class Settings; end

describe CalculateRelevance do

  before do
    Settings.should_receive(:user_relevancia_peso_topicos).and_return(2)
    Settings.should_receive(:user_relevancia_peso_apoios).and_return(1)
  end

  describe '.for_counters' do
    it 'calculates total relevance by formulas and values' do
      counters = {
        "topicos_count" => 1,
        "adesoes_count" => 2
      }

      formulas = {
        "topicos_count" => "user_relevancia_peso_topicos",
        "adesoes_count" => "user_relevancia_peso_apoios"
      }

      CalculateRelevance.for_counters(counters, formulas)["relevancia"].should == 400.to_f
    end
  end
end

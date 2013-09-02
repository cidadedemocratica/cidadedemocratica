require 'spec_helper'

describe User do
  let!(:topico) { FactoryGirl.create(:proposta) }

  describe '.update_counters' do
    before do
      Settings.topicos_relevancia_peso_apoios = 1
      Settings.topicos_relevancia_peso_seguidores = 1
      Settings.topicos_relevancia_peso_comentarios = 1
    end

    it 'calculates relevancia' do
      counters = {
        "adesoes_count" => 1,
        "seguidores_count" => 1,
        "comments_count" => 1
      }

      Topico.update_counters(topico.id, counters)
      topico.reload

      topico.relevancia.should eq 300
    end
  end
end

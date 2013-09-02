require 'spec_helper'

describe LocaisController do
  describe '#cidades_li_for_ul' do
    let(:cidade) { FactoryGirl.build(:cidade_sp_sao_paulo) }

    before do
      Cidade.stub_chain(:do_estado, :find).and_return { [cidade] }
    end

    context 'html response' do
      it 'updates ul_cidades' do
        template  = mock('template')

        controller.should_receive(:render).with(:update).and_yield(template)
        template.should_receive(:replace_html)
        controller.as_null_object

        get 'cidades_li_for_ul', cidades_selecionadas: ''
      end
    end
  end
end

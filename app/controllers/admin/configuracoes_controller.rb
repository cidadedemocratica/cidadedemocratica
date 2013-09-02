class Admin::ConfiguracoesController < Admin::AdminController
  
  def index
  end
  
  def salvar
    salva_configuracoes(params[:settings])
    flash[:notice] = "Configurações salvas"
    redirect_to :action => "index"
  end
  
  # Guarda valor do checkbox via AJAX
  def update_check_box
    salva_configuracoes(params[:settings])
    render :nothing => true
  end
  
  private
  
  def salva_configuracoes(settings)
    settings.each do |key, value|
      Settings[key] = value
    end
  end
  
end

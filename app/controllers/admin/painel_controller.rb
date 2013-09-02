class Admin::PainelController < Admin::AdminController
  
  def index
    @ultimos_topicos = Topico.find(:all, :limit => 4, :order => "id DESC")
    @ultimos_usuarios = User.ativos.find(:all, :limit => 4, :order => "id DESC")
    @ultimos_logins    = HistoricoDeLogin.find(:all, :limit => 4, :order => "id DESC", :include => :user)
    @ultimos_comentarios = Comment.find(:all, :limit => 4, :order => "id DESC")
  end
  
end

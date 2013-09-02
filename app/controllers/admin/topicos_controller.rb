class Admin::TopicosController < Admin::AdminController

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @topico = Topico.find(params[:id])
    @topico.destroy
    flash[:info] = "Tópico removido com sucesso."
    redirect_to root_url
  end

end

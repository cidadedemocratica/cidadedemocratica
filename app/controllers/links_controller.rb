class LinksController < ApplicationController
  before_filter :obter_topico
  
  def index
    @links = @topico.links
  end

  def create
    @link = Link.new(params[:link])
    @link.topico_id = @topico.id

    # Normaliza o http://
    if not @link.url.include? "http://"
      urlTemp = @link.url
      @link.url = "http://" << urlTemp
    end

    if @link.save
      flash[:notice] = "Link salvo com sucesso."
      redirect_to :action => "index", :topico_slug => @topico.to_param
    else
      flash[:error] = "Ocorreu um erro, verifique se é uma url válida."
      redirect_to :action => "index", :topico_slug => @topico.to_param
    end
  end

  def destroy
    @link = @topico.links.find(params[:id])
    if @link
      @link.destroy
      flash[:notice] = "Link removido com sucesso."
      redirect_to :action => "index", :topico_slug => @topico.to_param
    end
  end
  
  def update_positions
    params[:links_list].each_index do |i|
      link = Link.find(params[:links_list][i])
      link.position = i
      link.save
    end
    render :nothing => true
  end

  protected

  def obter_topico
    @topico = Topico.slugged_find(params[:topico_slug])
  end

end

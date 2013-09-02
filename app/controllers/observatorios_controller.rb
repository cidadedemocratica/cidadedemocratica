class ObservatoriosController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index ]
  before_filter :obter_observatorio, :except => [ :new, :create ]
  before_filter :obter_contadores, :only => [ :index, :comentarios, :apoios ]

  def index
    # @topicos = Topico.scoped(@observatorio.contexto).paginate(:per_page => 5, :page => params[:page], :order => "topicos.id DESC") if @observatorio
    @topicos = Topico.com_tags(@observatorio.tag_ids).nos_locais(@observatorio.locais).paginate(:per_page => 50, :page => params[:page], :order => "topicos.id DESC") if @observatorio

    unless current_user
      session[:observatorio] = 'observatorio'
    end

  end

  def new
    @observatorio = current_user.observatorios.build
    @tags = Tag.find(:all, :order => "name ASC")
  end

  def create
   #render :text => params.inspect
   @observatorio = current_user.observatorios.build(params[:observatorio])
   @observatorio.nome = "Observatório 1"
   if @observatorio.save
     if params[:local]
       params[:local].each do |p|
         #logger.debug ">>>>>>>> #{p.inspect}"
         @observatorio.locais.create(p[1])
       end
     end
     flash[:notice] = "Observatório criado com sucesso"
     redirect_to observatorio_url
   else
     @tags = Tag.find(:all, :order => "name ASC")
     render :action => "new"
   end
  end

  def edit
    @tags = Tag.find(:all, :order => "name ASC")
  end

  def salvar
    if @observatorio.update_attributes(params[:observatorio])
      @observatorio.locais.clear
      if params[:local]
        params[:local].each do |p|
          @observatorio.locais.create(p[1])
        end
      end
      flash[:notice] = "Observatório atualizado com sucesso"
      redirect_to observatorio_url
    else
      @tags = Tag.find(:all, :order => "name ASC")
      render :action => "edit"
    end
  end

  def comentarios
    @comentarios = Comment.paginate(:conditions => [ "commentable_type = 'Topico' AND commentable_id IN (?)", @topico_ids ],
                                    :order => "id DESC",
                                    :per_page => 50,
                                    :page => params[:page])
    render :action => "index"
  end

  def apoios
    @apoios = Adesao.dos_topicos(@observatorio.topico_ids.collect{ |t| t.id }).paginate(:order => "id DESC", :per_page => 50, :page => params[:page])
    render :action => "index"
  end

  protected

  def obter_observatorio
    @observatorio = user_signed_in? ? current_user.observatorios.first : nil
    @topico_ids = @observatorio ? Topico.com_tags(@observatorio.tag_ids).nos_locais(@observatorio.locais).all.collect{ |t| t.id } : []
  end

  def obter_contadores
    if @observatorio
      @topicos_count = @observatorio.topico_ids.size
      @comentarios_count = Comment.count(:conditions => [ "commentable_type = 'Topico' AND commentable_id IN (?)", @topico_ids ])
      @apoios_count = Adesao.dos_topicos(@topico_ids).size
    end
  end

end

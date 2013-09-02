class TopicosController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :new_localizar, :edit, :create, :seguir, :aderir, :destroy, :localizacao, :verificar_se_pode_editar ]
  before_filter :authenticate_admin!, :only => [:verificar_se_pode_editar]
  before_filter :redirect_to_local, :only => [ :index ]
  before_filter :verificar_se_pode_editar, :only => [ :edit, :update, :localizacao, :tags ]
  before_filter :obter_ordenacao, :only => [ :index ]
  before_filter :obter_localizacao, :only => [ :index ]
  before_filter :obter_tag, :only => [ :index ]
  before_filter :obter_tags_populares, :only => [:new, :new_localizar, :tags]
  before_filter :build_topico, :only => [:new, :new_localizar, :create]

  # Metodos que não precisam de authenticity token
  protect_from_forgery :except => [ :tags_by_link ]

  # Lista os tópicos de acordo com os filtros e ordenações escolhidas pelo
  # usuário.
  #
  # Filtra por:
  # * Cidade
  # * Bairro
  # * Tags
  # * Tempo (últimos 7, 30 ou todos)
  # * Tipo (proposta ou problema)
  #
  # Ordena por:
  # * Mais ativos (relevância)
  # * Mais recentes
  def index
    topicos = Topico.to_show.
      do_tipo(params[:topico_type]).
      do_proponente(params[:user_type]).
      do_pais(@pais).
      do_estado(@estado).
      da_cidade(@cidade).
      do_bairro(@bairro).
      com_tag(@tag)

    @topicos = topicos.includes(:tags, :user => [:dado, :imagens], :locais => [:estado, :cidade]).
      paginate(:order => @order, :page => params[:page])

    @topicos_user_stats = topicos.includes(:user).count(:group => "users.type") if !params[:user_type]

    # Filtros
    filtro_de_tags
    filtro_de_localizacao(topicos)

    if params[:rss] == "rss"
      request.format = :xml
      respond_to do |format|
        format.any do
           render :layout => "application.xml"
        end
      end
    else
      calcular_contadores(topicos)
    end
  end

  def new
    @step = 'description'
  end

  def new_localizar
    @step = 'localization'

    # avoid validate presence of locals
    @topico.editing_locals = true
    unless @topico.valid?
      @step = 'description'
      return render :new
    end

    if @competition.present?
      @topico.locais = @competition.locais.dup
    end

    prepare_localizacao_options
  end

  def create
    @topico.locais = Local.from_params(params[:locais])
    unless @topico.valid?
      @step = 'localization'
      prepare_localizacao_options
      return render :new_localizar
    end

    if @topico.save!
      warning_topic_enter_a_competition @topico

      current_user.tag(@topico, :with => @topico.tags_com_virgula, :on => :tags)

      flash[:notice] = "Congratulações: #{@topico.nome_do_tipo} cadastrad#{@topico.artigo_definido} com sucesso no Cidade Democrática."
      redirect_to topico_path(@topico)
    end
  end

  def show
    @topico = Topico.de_user_ativo.slugged_find(params[:topico_slug]) rescue nil
    if @topico
      @links = @topico.links.find(:all, :limit => 5, :order => "id DESC")
      @joining = @topico.joining
      @comentarios_all = @topico.comment_threads.desc
      @comentarios = @comentarios_all.includes(:user => [:dado, :imagens]).paginate(:page => params[:page], :per_page => 10)
      @topicos_relacionados = @topico.relacionados

      set_meta_tags TopicoMetaTags.for(request, @topico)
    else
      redirect_to topicos_url(:topico_type => "topicos") and return false
    end
  end

  def localizacao
    @topico = Topico.slugged_find(params[:topico_slug])
    prepare_localizacao_options

    if request.post?
      @topico.locais = Local.from_params(params[:locais])
      warning_topic_enter_a_competition @topico

      if @topico.save
        flash[:notice] = "Localização atualizada com sucesso."
        redirect_to topico_path(@topico)
      end
    end
  end

  def tags
    @topico = Topico.slugged_find(params[:topico_slug])

    # Insere mais tags na lista: apenas visual
    if request.xhr?
      insere_html_para_tags(params['topico']['tags_com_virgula'], :clear_field => true)
    end #xhr?

    # Post para salvar...
    if request.post? and not request.xhr?
      @topico.tags.clear
      str_tags  = params['tag']['name'].join(",") if params['tag'] and params['tag']['name']
      str_tags += ",#{params[:topico][:tags_com_virgula]}" unless params[:topico][:tags_com_virgula].blank?
      @topico.tags_com_virgula = str_tags
      current_user.tag(@topico, :with => str_tags, :on => :tags)
      if @topico.save
        flash[:notice] = "Tags alteradas com sucesso!"
        redirect_to topico_url(:topico_slug => @topico.to_param)
      end
      @topico.reload
      @topico.tags_com_virgula = "" #limpa o campo...
    end
  end

  def tags_by_link
    insere_html_para_tags(params["tag_name"])
  end

  def aderir
    topico = Topico.slugged_find(params[:topico_slug])
    if topico.user != current_user
      # Usuário já aderiu ao topico, remover adesao.
      aderiu = current_user.adesoes.find_by_topico_id(topico.id)
      if aderiu
        aderiu.destroy
        flash[:notice] = "Deixou de apoiar!"
      else
        # Usuário ainda não aderiu, incluí-lo.
        adesao = Adesao.create(:topico_id => topico.id, :user_id => current_user.id)
        TopicoMailer.nova_adesao(topico.id, adesao.id).deliver
        flash[:notice] = "Apoiou!"
      end
    end
    redirect_to topico_path(topico)
  end

  def denunciar
    @topico = Topico.de_user_ativo.slugged_find(params[:topico_slug])
    if @topico
      if request.post?
        if params['denuncia'] #Enviar o email com a denuncia
          AdminMailer.denuncia_em_topico(@topico.id, params[:denuncia]).deliver
          flash[:notice] = "Denúncia enviada. Sua mensagem será lida, analisada e, em breve, respondida."
        end
        redirect_to topico_url(:topico_slug => @topico.to_param)
      else
        render :partial => "form_denuncie"
      end
    else
      redirect_to topicos_url
    end
  end

  def logado_e_criador_do_topico?
    user_signed_in? && @topico.user == current_user
  end

  # Dado o titulo que o usuario digitou
  # mostrar os topicos similares para
  # evitar criar "duplicatas". APROVEITA
  # e sugere ao menos 3 TAGS relacionadas.
  def mostrar_similares
    exclude = @settings['relatorios_termos_excluidos'].split(",")

    used_words = (params[:search] || "").split(/\s+/).
      select { |w| w.size > 3 and not exclude.include?(w) }

    conditions_sql = if used_words.size > 0
      "titulo LIKE #{used_words.map { |w| "'%#{w}%'" }.join(' OR ')}"
    end

    topicos = Topico.do_tipo(params[:type]).
      find(:all, :conditions => conditions_sql, :limit => 5, :include => [:locais => :cidade])

    tags = used_words + topicos.map(&:tags).flatten.map(&:name)

    render :update do |page|
      page.replace_html "similares",
                        :partial => "topicos/similares",
                        :locals => { :topicos => topicos }
      page.replace_html "tags_possiveis",
                        :partial => "topicos/sugerir_tags",
                        :locals => {
                          :tags => tags.uniq
                        }
    end
  end

  # Edita um tópico
  def edit
    @topico = Topico.slugged_find(params[:topico_slug])
    @topico.tags_com_virgula = @topico.tags.collect { |t| t.name }.join(", ")
  end

  def update
    @topico = Topico.slugged_find(params[:topico_slug])
    if @topico.update_attributes(params[:topico])
      flash[:notice] = "Atualizamos #{@topico.nome_do_tipo(:artigo => :definido)} com sucesso!"
      redirect_to topico_url(:topico_slug => @topico.to_param)
    else
      render :action => "edit"
    end
  end

  def seguir
    @topico = Topico.slugged_find(params[:topico_slug])
    if @topico.user != current_user
      # Usuário já aderiu ao topico, remover adesao.
      seguiu = current_user.seguidos.find_by_topico_id(@topico.id)
      if seguiu
        seguiu.destroy
        flash[:notice] = "Deixou de seguir!"
      else
        # Usuário ainda não aderiu, incluí-lo.
        current_user.seguidos.create(:topico_id => @topico.id, :user_id => current_user.id)
        flash[:notice] = "Seguiu!"
      end
    end
    redirect_to topico_path(@topico)
  end

  protected

  def build_topico()
    model = params[:type] == "problema" ? Problema : Proposta
    @topico = model.new(params[:topico])
    @topico.user = current_user
    @topico.competition_id = params[:competition_id] if params[:competition_id]
    @competition = @topico.competition
  end

  def warning_topic_enter_a_competition(topico)
    unless topico.competition
      Competition.running.each do |competition|
        if competition.proposals_allowed? and topico.belongs_to_competition?(competition)
          TopicoMailer.warning_topic_enter_a_competition(topico.id, competition.id).deliver
        end
      end
    end
  end

  def prepare_localizacao_options
    @estados_selected = @topico.locais.select(&:estado_id).uniq(&:estado_id)
    @cidades_selected = @topico.locais.select(&:cidade_id).uniq(&:cidade_id)
    @bairros_selected = @topico.locais.select(&:bairro_id).uniq(&:bairro_id)

    @estados_id_selected = @estados_selected.map(&:estado_id)
    @cidades_id_selected = @cidades_selected.map(&:cidade_id)
    @bairros_id_selected = @bairros_selected.map(&:bairro_id)

    @estados_to_select = Estado.find(:all, :order => "abrev ASC, nome ASC")
    if @estados_id_selected.first
      @cidades_to_select = Cidade.do_estado(@estados_id_selected.first).includes(:estado).find(:all, :order => "nome ASC")
    else
      @cidades_to_select = []
    end
    if @cidades_id_selected.first
      @bairros_to_select = Bairro.da_cidade(@cidades_id_selected.first).includes(:cidade => [:estado]).find(:all, :order => "nome DESC")
    else
      @bairros_to_select = []
    end
  end

  private

  def redirect_to_local
    return unless params[:local]
    data = {}
    if params[:local][:estado_id]
      data[:estado_abrev] = Estado.find(params[:local][:estado_id]).abrev.downcase rescue nil
    end
    if params[:local][:cidade_id]
      data[:cidade_slug] = Cidade.find(params[:local][:cidade_id]).slug rescue nil
    end
    redirect_to topicos_path(data)
  end

  def obter_ordenacao
    case params[:order]
      when "relevancia"
        @order = "topicos.relevancia DESC"
      when "recentes"
        @order = "topicos.created_at DESC"
      when "antigos"
        @order = "topicos.created_at ASC"
      when "mais_comentarios"
        @order = "topicos.comments_count DESC"
      when "mais_apoios"
        @order = "topicos.adesoes_count DESC"
      when "a-z"
        @order = "topicos.titulo ASC"
      when "z-a"
        @order = "topicos.titulo DESC"
      else
        params[:order] = "relevancia"
        @order = "topicos.relevancia DESC"
    end
  end

  def obter_tag
    if !params[:tag_id].blank?
      @tag = Tag.find_by_id(params[:tag_id])
      unless @tag
        logger.info("  \e[1;31m404: Nao existe tag com ID = #{params[:tag_id]}.\e[0m")
        render :file => "#{Rails.root.to_s}/public/404.html", :layout => false, :status => 404 and return
      end
    end
  end

  def obter_tags_populares
    @tags = Tag.do_contexto(:topico_type => params[:type], :limit => 60)
  end

  def filtro_de_tags
    options = {
      :pais         => @pais,
      :estado       => @estado,
      :cidade       => @cidade,
      :bairro       => @bairro,
      :topico_type  => params[:topico_type],
      :limit        => 60 }

    @tags = if @tag
      Tag.relacionadas(@tag, options)
    else
      Tag.do_contexto(options)
    end
  end

  def filtro_de_localizacao(topicos)
    if !@estado
      @estados = topicos.joins(:locais => [:estado]).order("estados.nome").count(:group => ["estados.abrev", "estados.nome"]).map { |data, total| data + [total] }
    end

    if @estado and !@cidade
      @cidades = topicos.joins(:locais => [:estado, :cidade]).order("cidades.nome").count(:group => ["estados.abrev", "cidades.slug", "cidades.nome"]).map { |data, total| data + [total] }
    end

    if @estado and @cidade and !@bairro
      @bairros = topicos.joins(:locais => [:estado, :cidade, :bairro]).order("bairros.nome").count(:group => ["estados.abrev", "cidades.slug", "bairros.id", "bairros.nome"]).map { |data, total| data + [total] }
    end
  end

  def calcular_contadores(topicos)
    @contadores = {}
    @topicos_stats = topicos.count(:group => "topicos.type")

    @contadores[:propostas] = @topicos_stats["Proposta"] || 0
    @contadores[:problemas] = @topicos_stats["Problema"] || 0
    @contadores[:comentarios] = topicos.joins(:comment_threads).count("comments.id")
    @contadores[:adesoes] = topicos.joins(:adesoes).count("adesoes.id")
  end

  def verificar_se_pode_editar
    unless current_user.admin?
      @topico = Topico.slugged_find(params[:topico_slug])
      if !@topico.pode_editar? or current_user != @topico.user
        flash[:warning] = "Você não tem permissão para editar #{@topico.nome_do_tipo(:artigo => :definido)}."
        redirect_to topico_url(:topico_slug => @topico.to_param) and return false
      end
    end
  end

  def insere_html_para_tags(texto, options = {})
    if texto.blank?
      render :nothing => true
    else
      render :update do |page|
        texto.split(",").each do |t|
          page.insert_html :bottom,
                           "all_tags",
                           :partial => "tags_hidden",
                                       :locals => {
                                         :tag_name => t.strip
                                       }
        end
        # Limpa o campo de insercao
        page['topico_tags_com_virgula'].value = "" if options[:clear_field]
      end
    end
  end

end

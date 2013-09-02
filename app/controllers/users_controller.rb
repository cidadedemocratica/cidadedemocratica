class UsersController < ApplicationController
  before_filter :authenticate_admin!, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [ :suspend, :unsuspend, :destroy, :purge ]
  before_filter :authenticate_user!, :only => [ :complete, :solicitar_vinculacao, :vincular, :edit, :save, :descadastrar, :confirma_descadastro ]
  before_filter :obter_ordenacao, :only => [ :index ]
  before_filter :obter_localizacao, :only => [ :index ]

  skip_before_filter :complete_user_registration?, :only => [ :complete ]

  def index
    users = User.ativos.nao_admin.
      do_tipo(params[:user_type]).
      do_estado(@estado).
      da_cidade(@cidade).
      do_bairro(@bairro)

    filtro_de_localizacao(users)

    @users = users.includes(:dado, :imagens, :local => [:estado, :cidade]).
      paginate(:page => params[:page], :per_page => 15, :order => @order)
    @users_stats = users.count(:group => "users.type")
  end

  def complete
    # avoid redo user_dado
    unless current_user.pending?
      return redirect_to root_url
    end

    @user = current_user
    @user.local = Local.new(params[:local])

    @user_dado = UserDado.new(params[:user_dado])
    @user_dado.user = @user
    @user_dado.sexo = "m" if @user_dado.sexo.blank?

    @local = @user.local

    if request.post?
      if @user_dado.save
        @user.activate!

        if session[:novo_comentario]
          redirect_to create_comment_path
        else
          flash[:notice] = "Pronto! Você agora é parte do Cidade Democrática e pode apontar problemas, criar propostas e colaborar com outras pessoas e entidades."
          redirect_to perfil_path(@user)
        end
      end
    end
  end

  def show
    @user = User.includes(:imagens, :dado, :local => [ :cidade, :estado ]).find(params[:id])
    @tags = Tag.do_usuario(@user.id, :order => "total DESC", :limit => 30)
    show_activities

    # Evita mostrar perfil do admin
    if @user.admin? && @user != current_user
      return redirect_to(topicos_path)
    elsif !@user.active?
      flash[:warning] = "Usuário inativo, banido ou removido do sistema."
      return redirect_to(topicos_path)
    end

    respond_to do |wants|
      wants.html do
        render :layout => 'users_profile'
      end
      wants.rss do
        @atividades = @user.activities_summary(100)
        render :layout => false
      end
    end
  end

  def edit
    @user = current_user
    @user_dado = @user.dado
    @local = @user.local
    @imagem = Imagem.new
  end

  def save
    if current_user
      @user = current_user

      # Atualiza os dados básicos do usuário.
      @user_dado = @user.dado
      @user_dado.update_attributes(params[:user_dado])
      @user_dado.save

      # Atualiza o local.
      @local = @user.local ? @user.local : Local.new(:responsavel => @user)
      @local.estado_id = params[:local][:estado_id]
      @local.cidade_id = params[:local][:cidade_id]
      @local.bairro_id = params[:local][:bairro_id]
      @local.cep = params[:local][:cep]
      @local.save

      # Atribui o local atualizado ao usuário.
      @user.local = @local
      @user.save

      redirect_to :action => "show", :id => @user.id
    else
      flash[:error] = "Não há usuário corrente"
      redirect_to :back
    end
  end

  def localizacao
    @user = current_user
    @local = @user.local ? @user.local : Local.new
    @user.local = @local
    @local.attributes = params[:local]

    if request.post? or request.put?
      if @local.save
        flash[:notice] = "Localização atualizada com sucesso."
        redirect_to perfil_url(@user.id)
      end
    end
  end

  # Tela que avisa sobre o descadastro;
  # apenas para usuarios logados.
  def descadastrar
    @user = current_user
    @tags = Tag.do_usuario(@user.id, :order => "total DESC", :limit => 30).sort { |a, b| a.name <=> b.name }
    respond_to do |wants|
      wants.html do
        render :layout => 'users_profile'
      end
    end
  end

  def suspend
    @user.suspend!
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend!
    redirect_to users_path
  end

  def confirma_descadastro
    current_user.delete!
    logout_killing_session!
    redirect_to usuarios_url
  end

  def purge
    @user.delete!
    redirect_to users_path
  end

  def solicitar_vinculacao
    organizacao = User.find(params[:organizacao_id])
    UserMailer.solicitar_vinculacao(organizacao.id, current_user.id).deliver
    flash[:notice] = "Enviamos sua solicitação. A organização vai analisar sua solicitação e em breve responderá."
    redirect_to perfil_url(organizacao.id)
  end

  def vincular
    # O usuário logado é uma organização? Então pode vincular usuários.
    if current_user.organizacao?
      if user = User.find_by_id_criptografado(params[:user_id_criptografado])
        user.parent = current_user
        user.save

        # O usuário foi vinculado.
        # TODO: Notificar usuário vinculado por e-mail.
        flash[:notice] = "Usuário vinculado com sucesso."
        redirect_to perfil_url(current_user.id)
      end
    end
  end

  # Empresas, ongs e outros solicitando cadastros.
  def solicitar_cadastro_entidade
    if params[:solicitante][:email].strip.blank?
      render :update do |page|
        page.alert('Por favor, preencha corretamente seu email.')
      end
    elsif params[:solicitante][:nome].strip.blank?
      render :update do |page|
        page.alert('Por favor, preencha corretamente seu nome.')
      end
    elsif params[:solicitante][:entidade].strip.blank?
      render :update do |page|
        page.alert('Por favor, preencha corretamente o nome da entidade.')
      end
    else
      AdminMailer.pedido_cadastro_entidade(params[:solicitante]).deliver
      render :update do |page|
        page.alert('Obrigado. Seu contato foi recebido, em breve entraremos em contato por email.')
        page.hide("form_solicitacao")
      end
    end
  end

  def mensagem
    @user = User.find(params[:id])
    @contato = Contato.new

    if user_signed_in?
      @contato.nome = current_user.nome
      @contato.email = current_user.email
    end

    if request.post?
      @contato.nome = params[:contato][:nome]
      @contato.email = params[:contato][:email]
      @contato.mensagem = params[:contato][:mensagem]
      if verify_recaptcha(:model => @contato, :message => 'As palavras do captcha não conferem') && @contato.valid?
        @contato.enviar(@user)
        flash[:notice] = "Mensagem enviada com sucesso!"
        redirect_to perfil_url(@user)
      end
    end
  end

  def waiting_for_confirmation
    user = User.find(params[:id])
    @confirmation_link = confirmation_path(user, confirmation_token: user.confirmation_token)
  end

  private

  def show_activities
    if params[:type]
      @atividades = @user.send("activities_#{params[:type]}").paginate(:page => params[:page], :per_page => 10)
      @atividades_type = params[:type].to_sym
    else
      @atividades = @user.activities_summary
      @atividades_type = :resumo
    end
  end

  def obter_ordenacao
    case params[:order]
      when "relevancia"
        @order = "users.relevancia DESC"
      when "recentes"
        @order = "users.id DESC"
      when "mais_topicos"
        @order = "users.topicos_count DESC"
      when "mais_comentarios"
        @order = "users.comments_count DESC"
      when "mais_apoios"
        @order = "users.adesoes_count DESC"
      when "a-z"
        @order = "user_dados.nome ASC"
      when "z-a"
        @order = "user_dados.nome DESC"
      else
        params[:order] = "relevancia"
        @order = "users.relevancia DESC"
    end
  end

  def filtro_de_localizacao(users)
    if !@estado
      @estados = users.joins(:local => [:estado]).order("estados.nome").count(:group => ["estados.abrev", "estados.nome"]).map { |data, total| data + [total] }
    end

    if @estado and !@cidade
      @cidades = users.joins(:local => [:estado, :cidade]).order("cidades.nome").count(:group => ["estados.abrev", "cidades.slug", "cidades.nome"]).map { |data, total| data + [total] }
    end

    if @estado and @cidade and !@bairro
      @bairros = users.joins(:local => [:estado, :cidade, :bairro]).order("bairros.nome").count(:group => ["estados.abrev", "cidades.slug", "bairros.id", "bairros.nome"]).map { |data, total| data + [total] }
    end
  end

  protected

  def find_user
    @user = User.find(params[:id])
  end
end

class JoiningTopicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_joining_topic,              :except => [:new, :create]

  before_filter :authorized_to_author_or_admin,   :only => [:preview, :title_edit, :title_update, :description_edit, :description_update]
  before_filter :authorized_to_coauthor_or_admin, :only => [:suggest, :reject, :aprove]
  before_filter :authorized_to_authors_or_admin,  :only => [:show]

  before_filter :can_be_edited?,                  :only => [:preview, :title_edit, :title_update, :description_edit, :description_update]
  before_filter :can_be_evaluated?,               :only => [:suggest, :reject, :aprove]
  before_filter :validate_title,                  :only => [:description_edit, :description_update]

  before_filter :redirect_to_created_topico,      :only => [:show]

  def new
    @topico = Topico.find(params[:topico_id])
    @joining_related = @topico.joining_related

    flash[:warning] = "Esse tópico não pode ser unido pois não possui outros tópicos similares" unless @joining_related.present?
    flash[:warning] = "Esse tópico não pode ser unido" unless @topico.can_be_joined?

    unless flash[:warning]
      @joining_topic = JoiningTopic.new
      @joining_topic.topicos_from << @topico
    else
      redirect_to topico_path(@topico)
    end
  end

  def create
    joining_topic = JoiningTopic.new(params[:joining_topic])
    joining_topic.user = current_user
    joining_topic.current_phase = :propose_phase
    joining_topic.save!

    JoiningTopicMailer.created(joining_topic.id).deliver

    flash[:notice] = "Sua sugestão de união foi cadastrada com sucesso"
    redirect_to topico_path(joining_topic.topicos_from.first)
  end

  def preview

  end

  def title_edit

  end

  def title_update
    if not params[:joining_topic][:title].blank?
      @joining_topic.title = params[:joining_topic][:title]
      @joining_topic.save!
      redirect_to description_edit_joining_topic_path(@joining_topic)
    else
      flash[:warning] = "Você deve preencher o novo título"
      redirect_to title_edit_joining_topic_path(@joining_topic)
    end
  end


  def description_edit

  end

  def description_update
    if params[:joining_topic] and not params[:joining_topic][:description].blank?
      @joining_topic.description = params[:joining_topic][:description]
      @joining_topic.current_phase = :pending_phase
      @joining_topic.save!

      JoiningTopicMailer.pending_phase(@joining_topic.id).deliver

      flash[:notice] = "Proposta enviada para avaliação do co-autor"
      redirect_to joining_topic_path(@joining_topic)
    else
      flash[:warning] = "Você deve preencher a nova descrição"
      redirect_to description_edit_joining_topic_path(@joining_topic)
    end
  end


  def show

  end

  def suggest
    if params[:joining_topic] and not params[:joining_topic][:suggestion].blank?
      @joining_topic.current_phase = :author_phase
      @joining_topic.save!

      JoiningTopicMailer.suggest(@joining_topic.id, params[:joining_topic][:suggestion]).deliver

      flash[:notice] = "Suas sugestões foram enviadas para o autor"
      redirect_to joining_topic_path(@joining_topic)
    else
      flash[:warning] = "Você deve sugerir uma alteração"
      redirect_to joining_topic_path(@joining_topic)
    end
  end

  def reject
    @joining_topic.current_phase = :rejected_phase
    @joining_topic.save!

    JoiningTopicMailer.rejected(@joining_topic.id).deliver

    flash[:notice] = "Você rejeitou a união das suas propostas"
    redirect_to joining_topic_path(@joining_topic)
  end

  def aprove
    @joining_topic.current_phase = :aproved_phase
    @joining_topic.topico_to = create_topic

    if @joining_topic.save!
      # needed because of comments_count
      @joining_topic.topico_to.reset_counters

      AprovedJoiningTopicPostman.new(@joining_topic).deliver

      flash[:notice] = "Você aceitou a união das suas propostas"
      redirect_to joining_topic_path(@joining_topic)
    end
  end

  private

  def find_joining_topic
    @joining_topic   = JoiningTopic.find(params[:id])
    @author_topico   = @joining_topic.author_topico
    @coauthor_topico = @joining_topic.coauthor_topico
  end

  def create_topic
    topico = @joining_topic.topicos_from.first.class.new
    topico.titulo              = @joining_topic.title
    topico.descricao           = @joining_topic.description
    topico.user                = @joining_topic.author
    topico.competition         = @joining_topic.competition
    topico.locais              = @joining_topic.locais.map(&:dup)
    topico.links               = @joining_topic.links.map(&:dup)
    topico.imagens             = @joining_topic.imagens.map(&:dup)
    topico.usuarios_que_aderem = @joining_topic.usuarios_que_aderem

    # TODO: put this on topico's model
    topico.tags_com_virgula = @joining_topic.tags.map(&:name).join(',')
    topico.user.tag(topico, :with => topico.tags_com_virgula, :on => :tags)
    topico
  end

  def can_be_edited?
    unless @joining_topic.can_be_edited?
      flash[:warning] = "A união não pode ser editada"
      redirect_to joining_topic_path(@joining_topic)
    end
  end

  def can_be_evaluated?
    unless @joining_topic.can_be_evaluated?
      flash[:warning] = "A união não pode ser avaliada"
      redirect_to joining_topic_path(@joining_topic)
    end
  end

  def unauthorized
    flash[:warning] = "Você não pode acessar esta página"
    redirect_to root_path
  end

  def authorized_to_author_or_admin
    unauthorized if not admin_signed_in? and not @joining_topic.is_author?(current_user)
  end

  def authorized_to_coauthor_or_admin
    unauthorized if not admin_signed_in? and not @joining_topic.is_coauthor?(current_user)
  end

  def authorized_to_authors_or_admin
    authorized_to_author_or_admin unless @joining_topic.is_coauthor?(current_user)
  end

  def validate_title
    if @joining_topic.title.blank?
      redirect_to title_edit_joining_topic_path(@joining_topic)
    end
  end

  def redirect_to_created_topico
    if @joining_topic.topico_to.present?
      flash.keep
      redirect_to topico_path(@joining_topic.topico_to)
    end
  end
end

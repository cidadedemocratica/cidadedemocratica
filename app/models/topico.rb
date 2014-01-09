# encoding: utf-8

class Topico < ActiveRecord::Base
  include TopicoPresenter
  include ScopedByDateInterval

  COUNTERS_TO_RELEVANCE = {
    "seguidores_count" => "topicos_relevancia_peso_seguidores",
    "comments_count"   => "topicos_relevancia_peso_comentarios",
    "adesoes_count"    => "topicos_relevancia_peso_apoios"
  }.freeze
  TYPES = [
    ["Proposta", "Proposta"],
    ["Problema", "Problema"]
  ].freeze
  ORDERS = ["relevancia", "recentes", "antigos", "mais_comentarios", "mais_apoios", "a-z", "z-a"].freeze
  FEEDS = ["rss"].freeze

  # 1 usuário é responsável pelo problema.
  belongs_to :user, :include => [ :imagens, :dado ], :counter_cache => true

  belongs_to :competition

  # Se topico tem filhos
  acts_as_tree

  # O tópico tem TAGS!
  acts_as_taggable_on :tags

  # O tópico pode/deve ser mapeável (cidade, bairro, ponto no mapa...)
  has_many :locais, :as => :responsavel, :dependent => :destroy, :include => [ :estado, :cidade, :bairro ]

  # O tópico pode ter N imagens
  has_many :imagens, :as => :responsavel, :dependent => :destroy

  # O tópico pode ter N usuários que lhe são solidários
  has_many :adesoes, :dependent => :destroy
  has_many :usuarios_que_aderem, :through => :adesoes, :source => :user, :order => "created_at ASC"

  # O tópico pode ter N usuários que lhe seguem
  has_many :seguidos, :dependent => :destroy
  has_many :usuarios_que_seguem, :through => :seguidos, :source => :user

  # O tópico tem N pode ter links associados
  has_many :links, :dependent => :destroy

  # topic can have a joining
  has_one :joining_topico, :class_name => :JoiningTopicTopico
  has_one :joining, :through => :joining_topico, :source => :joining_topic, :conditions => { :current_phase_cd => 3 }

  # O tópico tem N comentários!
  acts_as_commentable
  has_many :usuarios_que_comentam, :through => :comment_threads, :source => :user

  # A slug do tópico (topico_slug!)
  has_slug :source_column => :titulo,
           :sync_slug => true # e se mudar o título?

  attr_accessor :tags_com_virgula, :editing_locals, :topico_type
  attr_accessible :competition_id, :titulo, :descricao, :tags_com_virgula, :topico_type

  def self.update_counters(id, counters)
    super id, CalculateRelevance.for_counters(counters, COUNTERS_TO_RELEVANCE)
  end

  def self.reset_counters(id, *counters)
    super
    object = find(id, :include => :joining_topico)
    # add joining topic comments_count if object is topico_to
    if counters.include?(:comment_threads) and object.joining_topico.present? and object.joining_topico.kind == "to"
      update_counters(id, :comments_count => object.joining.comments_count)
    end
  end

  # Don't use this method on application flow. Only for rake tasks
  def reset_counters
    Topico.reset_counters(id, :seguidos, :comment_threads, :adesoes)
    self.relevancia = CalculateRelevance.for_counters(reload.attributes, COUNTERS_TO_RELEVANCE)["relevancia"]
    self.save(:validate => false)
  end

  validates_presence_of :titulo, :descricao
  validate :must_have_tags, :if => Proc.new { |t| t.tags.empty? }
  validate :must_have_locais, :if => Proc.new { |t| not t.editing_locals }
  validate :must_have_locais_of_the_same_level, :if => Proc.new { |t| not t.editing_locals }
  validate :cant_have_identical_places, :if => Proc.new { |t| not t.editing_locals }
  validate :cant_exceed_locais_limit, :if => Proc.new { |t| not t.editing_locals }

  def must_have_tags
    if tags_com_virgula.nil? or tags_com_virgula.empty?
      errors.add(:base, "Precisa de ao menos uma tag")
    elsif tags_com_virgula.strip.empty?
      errors.add(:base, "Precisa de ao menos uma tag (não vazia!)")
    elsif tags_com_virgula.strip.gsub(/\,+/, ' ').strip.empty?
      errors.add(:base, "Tags, por favor...")
    elsif tags_com_virgula =~ /\"+|\'+|\t+/
      errors.add(:base, "Use palavras apenas com letras, números e espaços em branco")
    end
  end

  def must_have_locais
    if self.locais.size == 0
      errors.add(:base, "É preciso especificar ao menos uma localização")
    end
  end

  def must_have_locais_of_the_same_level
    if locais.map(&:ambito).uniq.size > 1
       errors.add(:base, "As localizações especificadas precisam ter todas a mesma abrangência")
    end
  end

  def cant_have_identical_places
    if locais.map(&:place).uniq.size != locais.size
      errors.add(:base, "Duas ou mais localizações especificadas são idênticas")
    end
  end

  def cant_exceed_locais_limit
    limit = 10
    if locais.size > limit
      errors.add(:base, "Não é possível especificar mais de #{limit} locais")
    end
  end

  scope :exclude_running_competitions, includes(:competition).where("topicos.competition_id IS NULL or competitions.finished = 1")

  scope :de_user_ativo, includes(:user).where('users.state = ?', 'active')

  scope :to_show, de_user_ativo.exclude_running_competitions.includes({ :user => [:imagens, :dado] }, { :locais => [:cidade, :estado] })

  scope :do_tipo, ->(type) do
    type = type.to_s.singularize.downcase.camelize
    return if type.blank? or type == "Topico"

    includes(:locais).where(:topicos => { :type => type })
  end

  scope :do_proponente, ->(type) do
    return if type.nil?
    includes(:user).where(:users => { :type => type.to_s.singularize.camelize })
  end

  scope :do_pais, ->(pais) do
    return if pais.nil? or not pais.kind_of?(Pais)
    includes_local_scope_builder(:pais_id => pais.id)
  end

  scope :do_estado, ->(estado) do
    return if estado.nil? or not estado.kind_of?(Estado)
    includes_local_scope_builder(:estado_id => estado.id)
  end

  scope :da_cidade, ->(cidade) do
    return if cidade.nil? or not cidade.kind_of?(Cidade)
    includes_local_scope_builder(:cidade_id => cidade.id)
  end

  scope :do_bairro, ->(bairro) do
    return if bairro.nil? or not bairro.kind_of?(Bairro)
     includes_local_scope_builder(:bairro_id => bairro.id)
  end

  scope :apos_o_dia, ->(inicio) do
    where("topicos.created_at >= ?", inicio)
  end

  scope :com_tags, ->(tag_ids) do
    return if tag_ids.nil? or tag_ids.empty?
    includes(:taggings).where(:taggings => { :tag_id => tag_ids })
  end

  scope :com_tag, ->(tag) do
    return if tag.nil?
    com_tags([tag.id])
  end

  scope :do_pai, ->(parent_id) { where(:parent_id => parent_id) }
  scope :exceto, ->(id) { where("topicos.id <> ?", id) }

  scope :nos_locais, lambda { |locais|
    if locais.nil?
      {}
    else
      tmp = []
      locais.each do |a|
        if a.cidade_id
          aux  = "(locais.cidade_id = #{a.cidade_id} "
          aux += "AND locais.bairro_id = #{a.bairro_id}" if a.bairro_id
          aux += ")"
          tmp << aux
        end
      end
      {
        :conditions => [ tmp.join(' OR ') ],
        :include => [ :locais ]
        #:joins => "INNER JOIN locais ON (locais.responsavel_id = topicos.id AND locais.responsavel_type = 'Topico')"
      }
    end
  }

  scope :desc, order("created_at DESC")

  def self.ignore_pagination
    except(:limit, :offset)
  end

  def self.maybe_tagged_with(tag)
    if tag.kind_of?(Tag)
      tag = tag.name
    end
    if tag
      # using any beacuse of cidadania and cidadânia for example
      tagged_with(tag, :any => true)
    else
      scoped
    end
  end

  def self.random_tags_to_cloud
    tag_counts.order("RAND()").limit(45)
  end

  def self.tags_to_cloud
    # removes select because of DISTINCT topicos.* added by tagged_with
    except(:select).ignore_pagination.tag_counts.order("count DESC").limit(45)
  end

  #==========================================================#
  #                  OBJECT Methods                          #
  #==========================================================#
  # Se o topico nao teve nenhuma atividade
  # (= comentario, adesao) ainda, pode ser editado.
  def pode_editar?
    (!competition and comment_threads.empty? and adesoes.empty?) or
    (competition and competition.proposals_allowed?)
  end

  def can_be_supported?
    !competition or competition.supports_allowed?
  end

  # only competition topic can be joined
  def can_be_joined?
    competition and competition.joinings_allowed? and not joining
  end

  def comments_allowed?
    !competition or competition.comments_allowed?
  end

  # Retorna o objeto da última atividade
  # TODO: melhorar
  def ultima_atividade
    if not self.comment_threads.empty?
      return self.comment_threads.last
    elsif not self.adesoes.empty?
      return self.adesoes.last
    else
      return nil
    end
  end

  # Retorna um vetor com
  # topicos relacionados.
  def relacionados
    Rails.cache.fetch(["Topico#relacionados", self.id, self.updated_at], :expires_in => 10.minutes) do
      relacionados = []
      # Se é filho de alguem, relacionar o pai
      relacionados << Topico.find(self.parent_id) if self.parent_id
      # Se tem filhos, relacionar os filhos
      Topico.do_pai(self.id).each{|t| relacionados << t }

      if local = self.locais.first
        # mesma cidade, mesmo bairro, mesmas tags
        Topico.da_cidade(local.cidade).do_bairro(local.bairro).order("topicos.id DESC").exceto(self.id).
          tagged_with(self.tags).limit(50).each{|t| relacionados << t }

        # mesma cidade, mesmas tags
        if relacionados.empty?
          Topico.da_cidade(local.cidade).order("topicos.id DESC").exceto(self.id).
            tagged_with(self.tags).limit(50).each{|t| relacionados << t }
        end

        # mesma cidade, mesmo bairro, qualquer uma das mesmas tags
        if relacionados.empty?
          Topico.da_cidade(local.cidade).do_bairro(local.bairro).order("topicos.id DESC").exceto(self.id).
            tagged_with(self.tags, :any => true).limit(50).each{|t| relacionados << t }
        end

        # mesma cidade, qualquer uma das mesmas tags
        if relacionados.empty?
          Topico.da_cidade(local.cidade).order("topicos.id DESC").exceto(self.id).
            tagged_with(self.tags, :any => true).limit(50).each{|t| relacionados << t }
        end
      end
      relacionados
    end
  end

  def joining_related
    return relacionados unless competition

    # belongs to the same competition
    proposals = competition.proposals.exceto(self.id)

    # share at least one tag
    proposals_top = proposals.tagged_with(self.tags, :any => true)

    # share at least one place
    proposals_top = proposals_top.select do |proposal|
      self.at_least_one_same_place? proposal
    end

    # After add all other proposals. The
    # proposal that match the criterious
    # are keeped on top
    (proposals_top + proposals).uniq
  end

  # Retorna true se o usuário apoia o tópico;
  # caso contrário, retorna false.
  def is_apoiado(user)
    user ? user.adesoes.find_by_topico_id(self.id) : false
  end

  # Retorna true se o usuário segue o tópico;
  # caso contrário, retorna false.
  def is_seguido(user)
    user ? user.seguidos.find_by_topico_id(self.id) : false
  end
  alias :usuario_segue? :is_seguido

  def belongs_to_competition?(competition)
    # having one local equal to competition means the topico belongs to it
    at_least_one_same_place? competition
  end

  # Returns true if the model have
  # at least one same place
  def at_least_one_same_place?(model)
    self.locais.any? do |self_local|
      model.locais.any? do |model_local|
        self_local.same_place? model_local
      end
    end
  end


  def self.divulgar(topico, divulgacao)
    for para_email in divulgacao.emails do
      TopicoMailer.divulgacao(topico.id,
                              divulgacao.de_nome,
                              divulgacao.de_email,
                              para_email,
                              divulgacao.dica).deliver
    end
    divulgacao.emails.size
  end

  protected

  def self.includes_local_scope_builder(options = {})
    includes(:locais).apply_local_conditions(options)
  end

  def self.apply_local_conditions(options)
    where(:locais => options)
  end
end

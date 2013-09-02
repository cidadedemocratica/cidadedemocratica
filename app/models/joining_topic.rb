class JoiningTopic < ActiveRecord::Base
  PHASES = [:propose_phase, :author_phase, :pending_phase, :aproved_phase, :rejected_phase].freeze

  attr_accessible :description, :observation, :title, :user_id, :author_id, :topicos_from_attributes

  as_enum :current_phase, PHASES

  validates_presence_of :user, :current_phase
  validate :validate_topicos_from_size

  belongs_to :user
  belongs_to :author, :class_name => :User

  has_many :topicos_from_relationships, :class_name => :JoiningTopicTopico, :conditions => { :kind => "from" }
  has_many :topicos_from, :through => :topicos_from_relationships, :source => :topico

  has_one  :topico_to_relationship, :class_name => :JoiningTopicTopico, :conditions => { :kind => "to" }
  has_one  :topico_to, :through => :topico_to_relationship, :source => :topico

  validates_associated :topicos_from, :topico_to

  accepts_nested_attributes_for :topicos_from
  def topicos_from_attributes=(attributes)
    attributes.each do |attributes|
      self.topicos_from << Topico.find(attributes["id"])
    end
  end

  def validate_topicos_from_size
    if topicos_from.size != 2
      errors.add(:topicos_from, "Wrong number of topicos_from")
    end
  end

  def competition
    topicos_from.first.competition
  end

  def expiration_date
    competition.expiration_date_from(:joining_phase) if competition
  end

  def expired?
    Date.today > expiration_date if expiration_date
  end

  def can_be_edited?
    not expired? and author_phase?
  end

  def can_be_evaluated?
    not expired? and pending_phase?
  end

  def author_topico
    (is_author?(topicos_from[0].user) ? topicos_from[0] : topicos_from[1]) if author
  end

  def coauthor_topico
    (is_author?(topicos_from[0].user) ? topicos_from[1] : topicos_from[0]) if author
  end

  def coauthor
    coauthor_topico.user if coauthor_topico
  end

  def is_author?(object)
    author == object
  end

  def is_coauthor?(object)
    coauthor == object
  end

  def topicos_from_attribute(attribute)
    topicos_from.map(&attribute).reduce(:+)
  end

  def tags
    topicos_from_attribute(:tags).uniq
  end

  def locais
    scopes = ["pais_id", "estado_id", "cidade_id", "bairro_id"]

    # filter locals to keep just resources with different
    # values at ids listed in scopes
    locais = topicos_from_attribute(:locais).uniq do |t|
      t.attributes.slice(*scopes)
    end

    scopes.each do |type|
      # try to find out a local without xxx_id defined
      founded_locais = locais.find_all { |local| not local.send(type).present? }
      # return founded place because its on top scope
      if founded_locais.size > 0
        return founded_locais
      end
    end
    return locais
  end

  def links
    topicos_from_attribute(:links).uniq { |t| t.url }
  end

  def imagens
    topicos_from_attribute(:imagens)
  end

  def usuarios_que_seguem
    topicos_from_attribute(:usuarios_que_seguem).uniq
  end

  def usuarios_que_aderem
    topicos_from_attribute(:usuarios_que_aderem).uniq
  end

  def comments_count
    topicos_from_attribute(:comments_count)
  end

  def human_current_phase
    I18n.t("activerecord.enums.joining_topic.current_phases.#{current_phase}")
  end
end

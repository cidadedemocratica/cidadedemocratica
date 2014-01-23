class Competition < ActiveRecord::Base
  include Activities::Competition
  PHASES = [:inspiration_phase, :proposals_phase, :support_phase, :joining_phase, :announce_phase].freeze
  ORDERS = ["recentes", "relevancia", "mais_comentarios", "mais_apoios"].freeze
  DOMAINS = {
    "cidadonos.org.br" => { :id => 5 },
    "varzea2022.sp.gov.br" => { :id => 3 }
  }

  has_many :inspirations
  has_many :proposals, :class_name => "Proposta"
  has_many :locais, :as => :responsavel, :dependent => :destroy, :include => [ :estado, :cidade, :bairro ]
  has_many :prizes, :class_name => "CompetitionPrize"
  alias_method :competition_prizes, :prizes

  accepts_nested_attributes_for :locais, :allow_destroy => true

  validates_presence_of :title, :short_description, :long_description, :author_description, :start_date, :inspiration_phase, :proposals_phase, :support_phase, :joining_phase, :announce_phase, :regulation, :awards, :image

  mount_uploader :image, ImageUploader
  as_enum :current_phase, PHASES

  attr_accessible :title, :short_description, :long_description, :author_description, :start_date, :finished,
    :inspiration_phase, :proposals_phase, :support_phase, :joining_phase, :announce_phase,
    :image_cache, :regulation, :awards, :partners, :published, :locais_attributes, :image

  scope :published, where(:published => true)
  scope :started, lambda { where('start_date <= ?', Date.today) }
  scope :unfinished, published.where(:finished => false)
  scope :finished, published.where(:finished => true)
  scope :running, started.unfinished
  scope :desc, order("created_at DESC")

  def to_param
    "#{id} #{title}".parameterize
  end

  def set_default_phases
    PHASES.each do |phase|
      send "#{phase}=", 18
    end
  end

  def future_phase?(phase)
    PHASES.index(current_phase) < PHASES.index(phase)
  end

  def phase_enabled?(phase)
    send(phase) > 0
  end

  def phase_over?(phase)
    finished? or PHASES.index(phase) < PHASES.index(current_phase)
  end

  def supports_allowed?
    current_phase == :support_phase or finished?
  end

  def inspirations_allowed?
    current_phase == :inspiration_phase
  end

  def proposals_allowed?
    current_phase == :proposals_phase
  end

  def comments_allowed?
    current_phase == :proposals_phase or finished?
  end

  def joinings_allowed?
    current_phase == :joining_phase
  end

  def enabled_phases
    PHASES.select { |p| phase_enabled? p }
  end

  def calculate_current_phase
    phase = enabled_phases.find { |p| remaining_days_from(p) > 0 }

    self.finished = phase.nil?
    self.current_phase = phase || enabled_phases.last
  end

  def remaining_days
    remaining_days_from PHASES.last
  end

  def remaining_days_in_current_phase
    remaining_days_from current_phase
  end

  def remaining_days_from(phase)
    [(expiration_date_from(phase) - Date.today).to_i, 0].max
  end

  def expiration_date_from(phase)
    days = 0
    PHASES.each do |p|
      days += send(p)
      break if p == phase
    end
    start_date.to_date + days
  end

  def before_expiration_time_from(phase)
    (expiration_date_from(phase) - 1).end_of_day
  end

  def prizes_with_defined_winning_topic
    competition_prizes.where("winning_topic_id IS NOT NULL")
  end

  def participants
    User.where("
      id IN (SELECT topicos.user_id FROM topicos WHERE topicos.competition_id = :competition_id) OR
      id IN (SELECT inspirations.user_id FROM inspirations WHERE inspirations.competition_id = :competition_id) OR
      id IN (SELECT comments.user_id FROM comments INNER JOIN topicos ON topicos.competition_id = :competition_id AND comments.commentable_id = topicos.id AND commentable_type = 'Topico') OR
      id IN (SELECT adesoes.user_id FROM adesoes INNER JOIN topicos ON topicos.competition_id = :competition_id AND adesoes.topico_id = topicos.id) OR
      id IN (SELECT seguidos.user_id FROM seguidos INNER JOIN topicos ON topicos.competition_id = :competition_id AND seguidos.topico_id = topicos.id)
    ", :competition_id => id)
  end

  def participants_count
    Rails.cache.fetch(["Competition#participants_count", id], :expires_in => 10.minutes) do
      participants.count
    end
  end

  def human_current_phase
    I18n.t("activerecord.attributes.competition.#{current_phase}")
  end

  def to_s
    title
  end
end

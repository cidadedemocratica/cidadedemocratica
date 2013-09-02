class GeneralReport
  TYPES = [:base, :tags_matrix, :locals_matrix, :users_matrix]
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks

  include Virtus

  define_model_callbacks :initialize, :only => :after

  attribute :type, String
  attribute :to, Date, :default => Date.today
  attribute :from, Date, :default => :default_from
  attribute :competition_id, Integer
  attribute :state_ids, Array[Integer]
  attribute :city_ids, Array[Integer]
  attribute :macro_tags
  attribute :tags, Array[String]

  after_initialize :clean_select_multiple

  def initialize(attributes = {})
    run_callbacks :initialize do
      super(attributes)
    end
  end

  def competition
    Competition.find(competition_id) unless competition_id.blank?
  end

  def states
    Estado.find(state_ids) if state_ids.size > 0
  end

  def cities
    Cidade.find(city_ids) if city_ids.size > 0
  end

  def persisted?
    false
  end

  def default_from
    to.beginning_of_month
  end

  def local_scoped
    if state_ids.size > 0
      { :field => :cidade_id, :model => Cidade }
    elsif city_ids.size > 0
      { :field => :bairro_id, :model => Bairro }
    else
      { :field => :estado_id, :model => Estado }
    end
  end

  def all_topics
    @all_topics ||= topics_related_to(:interval, :tags, :locals, :competition)
  end

  def topics
    @topics ||= topics_no_matter_interval.includes(:locais, :user => :dado).at_interval(from, to).all
  end

  def topics_no_matter_interval
    @topics_no_matter_interval ||= topics_related_to(:tags, :locals, :competition)
  end

  def adesoes
    @adesoes ||= resource_of_topics(Adesao, :topico => :locais, :user => :dado)
  end

  def seguidos
    @seguidos ||= resource_of_topics(Seguido, :topico => :locais, :user => :dado)
  end

  def comments
    @comments ||= resource_of_topics(Comment, :commentable => [:locais, :joining_topico, :joining], :user => :dado)
  end

  def collections
    [topics, adesoes, seguidos, comments].select { |c| c.size > 0 }.map do |c|
      [c.first.class.table_name, c]
    end
  end

  def allowed_tags
    topics = topics_related_to :interval, :locals, :competition
    Tag.includes(:taggings).where(:taggings => { :taggable_type => "Topico", :taggable_id => topics })
  end

  def tags_grouped_by_topics
    all_topics.includes(:tags).map { |t| t.tags.pluck(:name) }
  end

  def locals_grouped_by_topics
    all_topics.includes(:locais => [:estado, :cidade, :bairro]).map { |t| t.locais.map(&:descricao) }
  end

  protected

  def topic_ids_no_matter_interval
    @topic_ids_no_matter_interval ||= topics_no_matter_interval.pluck(:id)
  end

  def topic_ids_no_matter_tags_locals_competition
    ids = []
    { Topico => :id, Adesao => :topico_id, Seguido => :topico_id, Comment.by_topic => :commentable_id }.each do |model, field|
      ids += model.at_interval(from, to).pluck(field)
    end
    ids.uniq
  end

  def resource_of_topics(model, options = {})
    model.dos_topicos(topic_ids_no_matter_interval).includes(options).at_interval(from, to).all
  end

  def topics_related_to(*condititions)
    model = Topico
    condititions.each do |condition|
      model = case condition
        when :tags
          model.tagged_with(tags, :any => true)
        when :interval
          model.where(:id => topic_ids_no_matter_tags_locals_competition)
        when :locals
          locals_conditions.blank? ? model : model.joins(:locais).where(locals_conditions)
        when :competition
          competition_condition.blank? ? model : model.where(competition_condition)
      end
    end
    model
  end


  def locals_conditions
    condititions = []
    condititions << "locais.estado_id IN(#{state_ids.join(",")})" if state_ids.size > 0
    condititions << "locais.cidade_id IN(#{city_ids.join(",")})" if city_ids.size > 0
    condititions.join(" OR ")
  end

  def competition_condition
    "topicos.competition_id = #{competition_id}" unless competition.blank?
  end


  # http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select-using-an-embedde
  def clean_select_multiple
    %w(state_ids city_ids tags).each do |attribute|
      send(attribute).reject!(&:blank?)
    end
  end
end

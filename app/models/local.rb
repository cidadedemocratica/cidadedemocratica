class Local < ActiveRecord::Base
  belongs_to :responsavel, :polymorphic => true#, :dependent => :destroy # bug no cadastro de pessoas
  belongs_to :pais
  belongs_to :estado
  belongs_to :cidade
  belongs_to :bairro

  attr_accessible :pais_id, :estado_id, :cidade_id, :bairro_id, :cep, :cidade

  validates_presence_of :pais_id
  validates_presence_of :estado_id,             :if => :tem_cidade?
  validates_presence_of :estado_id, :cidade_id, :if => :tem_bairro?

  validate :cidade_pertence_ao_estado,          :if => :tem_cidade?
  validate :bairro_pertence_a_cidade,           :if => :tem_bairro?

  scope :de_usuario, :conditions => ["responsavel_type = 'User'"]
  scope :de_topicos, :conditions => ["responsavel_type = 'Topico'"]

  # Receive data in this format:
  #  - local[pais_id] = xx | [xx,yy]
  #  - local[pais_id][xx][estado_id] = xx | [xx,yy]
  #  - local[pais_id][xx][estado_id][xx][cidade_id] = xx | [xx,yy]
  #  - local[pais_id][xx][estado_id][xx][cidade_id][xx][bairro_id] = xx | [xx,yy]
  # Should return a hash to create a Local model
  def self.from_params(input)
    storage = []
    a_model = { :pais_id => nil, :estado_id => nil, :cidade_id => nil, :bairro_id => nil }

    parser = Proc.new do |model, value, field = nil|
      if value.is_a? Hash
        value.keys.each do |item|
          # pass the key like one field
          if field.nil?
            parser.call(model, value[item], item.to_sym)
          # after a field the keys are always field ids
          else
            copy = model.clone()
            copy[field] = item
            parser.call(copy, value[item])
          end
        end

      elsif value.is_a? Array
        # an array are always a list of field ids
        value.each do |v|
          parser.call(model, v, field)
        end

      else
        # string value is the end of current
        # model and should be stored
        copy = model.clone()
        copy[field] = value
        storage << copy
      end
    end

    if input.present?
      parser.call(a_model, input)

      list = storage.map do |hash|
        Local.new(hash)
      end
      list.select(&:valid?)
    else
      []
    end
  end

  def pais_id
    read_attribute(:pais_id) or 1
  end

  def place
    attributes.slice("pais_id", "estado_id", "cidade_id", "bairro_id")
  end

  def same_place?(object)
    object.instance_of?(Local) and object.place == place
  end

  def ambito
    if tem_bairro?
      "local"
    elsif tem_cidade?
      "municipal"
    elsif tem_estado?
      "estadual"
    else
      "nacional"
    end
  end

  def tem_pais?
    pais
  end

  def tem_estado?
    estado
  end

  def tem_cidade?
    cidade
  end

  def tem_bairro?
    bairro
  end

  def to_link_hash
    {
      :estado_abrev => estado && estado.abrev.downcase,
      :cidade_slug => cidade && cidade.slug,
      :bairro_id => bairro_id
    }
  end

  def descricao
    return "Todo o país" if ambito == "nacional"
    ret = []
    ret << "#{bairro.nome}," if tem_bairro?
    ret << "#{cidade.nome} -" if tem_cidade?
    ret << "#{estado.abrev}" if tem_estado?
    ret.join(" ")
  end
  alias_method :to_s, :descricao

  private

  def cidade_pertence_ao_estado
    if cidade and cidade.estado_id != estado_id
      errors.add(:cidade_id, :invalid, :default => "não pertence ao estado informado", :value => cidade_id)
    end
  end

  def bairro_pertence_a_cidade
    if bairro and bairro.cidade_id != cidade_id
      errors.add(:bairro_id, :invalid, :default => "não pertence à cidade informada", :value => bairro_id)
    end
  end

end

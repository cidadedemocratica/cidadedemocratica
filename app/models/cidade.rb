class Cidade < ActiveRecord::Base
  belongs_to :estado
  has_many :bairros, :dependent => :destroy
  has_many :locais, :dependent => :destroy
  attr_accessible :nome, :estado_id

  validates_presence_of :nome, :estado

  scope :do_estado, lambda { |estado_id|
    if estado_id.blank?
      { }
    else
      { :conditions => [ "cidades.estado_id = ?", estado_id ],
        :order => "cidades.nome ASC" }
    end
  }

  def to_s
    "#{nome} - #{estado.abrev}"
  end
end

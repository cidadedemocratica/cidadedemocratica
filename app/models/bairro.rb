# encoding : utf-8
class Bairro < ActiveRecord::Base
  belongs_to :cidade
  has_many :locais

  attr_accessible :nome, :cidade_id

  validates_presence_of :nome, :cidade_id

  scope :da_cidade, lambda { |cidade_id|
    if cidade_id.blank?
      { }
    else
      { :conditions => [ "bairros.cidade_id = ?", cidade_id ],
        :order => "bairros.nome ASC" }
    end
  }

  def to_s
    nome
  end
end

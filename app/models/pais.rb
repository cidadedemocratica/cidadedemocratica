class Pais < ActiveRecord::Base
  validates_presence_of :iso, :nome
  attr_accessible :iso, :nome

  def to_s
    self.nome
  end
end

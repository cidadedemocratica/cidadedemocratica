class Estado < ActiveRecord::Base
  has_many :cidades, :dependent => :destroy
  attr_accessible :nome, :abrev

  validates_presence_of :nome, :abrev

  def slug
    self.abrev.to_s.downcase
  end

  def to_s
    "#{nome}"
  end
end

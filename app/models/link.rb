class Link < ActiveRecord::Base
  belongs_to :topico
  validates_presence_of :nome
  validates_format_of :url, :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z/ix

  attr_accessible :nome, :url, :position
end

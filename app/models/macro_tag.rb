class MacroTag < ActiveRecord::Base
  attr_accessible :title, :tag_list

  validates :title, :presence => true

  acts_as_taggable
end

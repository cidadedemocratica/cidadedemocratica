class Adesao < ActiveRecord::Base
  include ScopedByDateInterval

  belongs_to :user, :counter_cache => true
  belongs_to :topico, :counter_cache => true

  attr_accessible :topico_id, :user_id
  validates_uniqueness_of :topico_id, :scope => :user_id

  scope :por_user_ativo,
              :include => [:user],
              :conditions => ["users.state = 'active'"]
  scope :dos_topicos, lambda { |topico_ids|
    if topico_ids.nil?
      { }
    else
      {
        :conditions => [ "topico_id IN (?)", topico_ids ]
      }
    end
  }
  scope :depois_de, lambda { |data|
    if data.nil?
      { :order => "created_at DESC" }
    else
      { :conditions => [ "created_at >= ?", data ],
        :order => "created_at DESC" }
    end
  }

  scope :desc, order("created_at DESC")
end

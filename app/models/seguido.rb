class Seguido < ActiveRecord::Base
  include ScopedByDateInterval

  belongs_to :user
  belongs_to :topico, :counter_cache => "seguidores_count"

  validates_uniqueness_of :topico_id, :scope => :user_id

  attr_accessible :topico_id, :user_id

  scope :por_user_ativo,
              :include => [:user],
              :conditions => ["users.state = 'active'"]

  scope :desc, order("created_at DESC")

  scope :dos_topicos, lambda { |topico_ids|
    if topico_ids.nil?
      { }
    else
      {
        :conditions => [ "topico_id IN (?)", topico_ids ]
      }
    end
  }
end

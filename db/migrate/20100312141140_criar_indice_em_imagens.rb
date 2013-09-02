class CriarIndiceEmImagens < ActiveRecord::Migration
  def self.up
    add_index :imagens, [ :responsavel_id, :responsavel_type ], :name => :by_responsavel_id_and_type
  end

  def self.down
    remove_index :imagens, :name => :by_responsavel_id_and_type
  end
end
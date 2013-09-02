class EnhanceWithIndexes < ActiveRecord::Migration
  def self.up
    add_index :bairros, [:cidade_id, :nome]
    add_index :cidades, [:estado_id, :nome]
    add_index :estados, :abrev
    
    add_index :adesoes, :user_id
    add_index :adesoes, :topico_id
    add_index :comments, [:commentable_id, :commentable_type]
    add_index :links, [:topico_id, :position]
    add_index :tags, :name    
  end

  def self.down
    remove_index :bairros, [:cidade_id, :nome]
    remove_index :cidades, [:estado_id, :nome]
    remove_index :estados, :abrev
    
    remove_index :adesoes, :user_id
    remove_index :adesoes, :topico_id
    remove_index :comments, [:commentable_id, :commentable_type]
    remove_index :links, [:topico_id, :position]
    remove_index :tags, :name
  end
end

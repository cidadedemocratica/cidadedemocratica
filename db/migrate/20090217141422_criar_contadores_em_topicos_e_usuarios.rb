class CriarContadoresEmTopicosEUsuarios < ActiveRecord::Migration
  def self.up
    add_column :topicos, :comments_count, :integer, :default => 0
    add_column :topicos, :adesoes_count, :integer, :default => 0
    add_column :topicos, :relevancia, :integer, :default => 0

    add_column :users, :topicos_count, :integer, :default => 0
    add_column :users, :comments_count, :integer, :default => 0
    add_column :users, :adesoes_count, :integer, :default => 0
    add_column :users, :relevancia, :integer, :default => 0

    add_index :topicos, :comments_count
    add_index :topicos, :adesoes_count
    add_index :topicos, :relevancia

    add_index :users, :topicos_count
    add_index :users, :comments_count
    add_index :users, :adesoes_count
    add_index :users, :relevancia
  end

  def self.down
    remove_column :topicos, :comments_count
    remove_column :topicos, :adesoes_count
    remove_column :topicos, :relevancia

    remove_column :users, :topicos_count
    remove_column :users, :comments_count
    remove_column :users, :adesoes_count
    remove_column :users, :relevancia
  end
end
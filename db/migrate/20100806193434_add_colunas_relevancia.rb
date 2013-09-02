class AddColunasRelevancia < ActiveRecord::Migration
  def self.up
    # Estava faltando contar os "seguidores" do topico...
    add_column :topicos, :seguidores_count, :integer, :default => 0
    add_index :topicos, :seguidores_count
    
    # Agora será importante calcular a "relevancia" dos territorios e temas/tags
    add_column :estados, :relevancia, :integer, :default => 0
    add_column :cidades, :relevancia, :integer, :default => 0
    add_column :bairros, :relevancia, :integer, :default => 0
    add_column :tags, :relevancia, :integer, :default => 0
    
    # Indices das colunas criadas...
    add_index :estados, :relevancia
    add_index :cidades, :relevancia
    add_index :bairros, :relevancia
    add_index :tags, :relevancia
    
    # Para ordenarmos os apoiadores pelo momento de apoio...
    add_index :adesoes, :created_at
  end

  def self.down
    remove_column :topicos, :seguidores_count
    remove_column :estados, :relevancia
    remove_column :cidades, :relevancia
    remove_column :bairros, :relevancia
    remove_column :tags, :relevancia
  end
end

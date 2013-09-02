class AjustaLocalizacao < ActiveRecord::Migration
  def self.up
    create_table :paises do |t|
      t.string :iso, :limit => 2
      t.string :nome
      t.timestamps
    end
    p = Pais.create(:iso => "BR", :nome => "Brasil")
    
    add_column :locais, :estado_id, :integer
    add_column :locais, :pais_id, :integer
    
    add_index :locais, :estado_id
    add_index :locais, :pais_id

    Local.update_all("bairro_id = NULL", "bairro_id = 0")
    Local.all.each do |l|
      puts l.inspect
      if (not l.blank? and l.cidade_id and l.cidade)
        l.update_attributes(:estado_id => l.cidade.estado_id, :pais_id => p.id)
      else
        l.update_attributes(:pais_id => p.id)
      end
    end
  end

  def self.down
    drop_table :paises
    
    remove_column :locais, :estado_id
    remove_column :locais, :estado_id
  end
end

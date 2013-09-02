class CreateCidades < ActiveRecord::Migration
  def self.up
    create_table :cidades do |t|
      t.string :nome
      t.integer :estado_id
      t.string :slug

      t.timestamps
    end
    add_index :cidades, :slug
  end

  def self.down
    drop_table :cidades
  end
end

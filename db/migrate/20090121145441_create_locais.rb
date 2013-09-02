class CreateLocais < ActiveRecord::Migration
  def self.up
    create_table :locais, :force => true do |t|
      t.references :responsavel, :polymorphic => true

      t.integer :bairro_id
      t.integer :cidade_id
      t.decimal  :lat, :precision => 15, :scale => 10
      t.decimal  :lng, :precision => 15, :scale => 10

      t.timestamps
    end

    add_index :locais, :bairro_id
    add_index :locais, :cidade_id
    add_index :locais, [:responsavel_id, :responsavel_type]

  end

  def self.down
    drop_table :locais
  end
end
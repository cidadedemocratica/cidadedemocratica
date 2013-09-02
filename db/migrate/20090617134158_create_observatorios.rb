class CreateObservatorios < ActiveRecord::Migration
  def self.up
    create_table :observatorios do |t|
      t.integer :user_id
      t.string :nome
      t.boolean :receber_email, :default => true
      t.timestamps
    end
    
    create_table :observatorios_tem_tags, :id => false do |t|
      t.integer :observatorio_id
      t.integer :tag_id
    end
    
    add_index :observatorios, :user_id
    add_index :observatorios_tem_tags, [:observatorio_id, :tag_id ], :unique => true
  end

  def self.down
    drop_table :observatorios
    drop_table :observatorios_tem_tags
  end
end

class CreateTemas < ActiveRecord::Migration
  def self.up
    create_table :temas do |t|
      t.string :nome
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :slug

      t.timestamps
    end
    add_index :temas, :slug
  end

  def self.down
    drop_table :temas
  end
end
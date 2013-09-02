class CreateNings < ActiveRecord::Migration
  def self.up
    create_table :nings do |t|
      t.integer :user_id
      t.integer :source_id
      t.string :owner_id
      t.string :apps_id
      t.timestamps
    end
  end

  def self.down
    drop_table :nings
  end
end

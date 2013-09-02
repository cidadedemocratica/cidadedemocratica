class CreateTableInspirations < ActiveRecord::Migration
  def self.up
    create_table :inspirations do |t|
      t.integer :competition_id
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :inspirations
  end
end

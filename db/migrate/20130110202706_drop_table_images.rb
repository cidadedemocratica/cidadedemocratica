class DropTableImages < ActiveRecord::Migration
  def self.up
    drop_table :images
  end

  def self.down
    create_table :images do |t|
      t.references :owner, :polymorphic => true

      t.string :image

      t.timestamps
    end
  end
end

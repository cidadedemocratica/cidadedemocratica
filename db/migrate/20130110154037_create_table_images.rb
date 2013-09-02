class CreateTableImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.references :owner, :polymorphic => true

      t.string :image

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end

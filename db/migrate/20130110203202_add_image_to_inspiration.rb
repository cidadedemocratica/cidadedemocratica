class AddImageToInspiration < ActiveRecord::Migration
  def self.up
    add_column :inspirations, :image, :string
  end

  def self.down
    remove_column :inspirations, :image
  end
end

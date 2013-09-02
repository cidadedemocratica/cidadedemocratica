class AddTitleToInspirations < ActiveRecord::Migration
  def self.up
    add_column :inspirations, :title, :string
  end

  def self.down
    remove_column :inspirations, :title
  end
end

class AddUserIdToInspirations < ActiveRecord::Migration
  def self.up
    add_column :inspirations, :user_id, :integer
  end

  def self.down
    remove_column :inspirations, :user_id
  end
end

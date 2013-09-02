class AddInspirationsCountToUser < ActiveRecord::Migration
  def up
    add_column :users, :inspirations_count, :integer
  end

  def down
    remove_column :users, :inspirations_count
  end
end

class RemoveLocalIdFromCompetitions < ActiveRecord::Migration
  def up
    remove_column :competitions, :local_id
  end

  def down
    add_column :competitions, :local_id, :integer
  end
end

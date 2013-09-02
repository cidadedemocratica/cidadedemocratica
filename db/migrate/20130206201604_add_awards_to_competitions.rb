class AddAwardsToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :awards, :text
  end

  def self.down
    remove_column :competitions, :awards
  end
end

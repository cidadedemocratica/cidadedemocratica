class AddFinishedToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :finished, :boolean, :default => false
  end

  def self.down
    remove_column :competitions, :finished
  end
end

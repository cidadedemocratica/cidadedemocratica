class AddRegulationToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :regulation, :text
  end

  def self.down
    remove_column :competitions, :regulation
  end
end

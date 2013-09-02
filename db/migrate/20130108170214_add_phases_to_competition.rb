class AddPhasesToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :inspiration_phase, :integer
    add_column :competitions, :proposals_phase, :integer
    add_column :competitions, :support_phase, :integer
    add_column :competitions, :joining_phase, :integer
    add_column :competitions, :announce_phase, :integer
  end

  def self.down
    remove_column :competitions, :inspiration_phase
    remove_column :competitions, :proposals_phase
    remove_column :competitions, :support_phase
    remove_column :competitions, :joining_phase
    remove_column :competitions, :announce_phase
  end
end

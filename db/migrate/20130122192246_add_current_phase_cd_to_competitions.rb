class AddCurrentPhaseCdToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :current_phase_cd, :integer
  end

  def self.down
    remove_column :competitions, :current_phase_cd
  end
end

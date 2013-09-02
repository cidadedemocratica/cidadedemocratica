class AddPartnersToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :partners, :text
  end

  def self.down
    remove_column :competitions, :partners
  end
end

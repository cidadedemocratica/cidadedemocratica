class RenameDescriptionToShortDescriptionOnCompetitions < ActiveRecord::Migration
  def self.up
    rename_column :competitions, :description, :short_description
  end

  def self.down
    rename_column :competitions, :short_description, :description
  end
end

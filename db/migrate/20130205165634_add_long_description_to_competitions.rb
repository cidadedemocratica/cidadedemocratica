class AddLongDescriptionToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :long_description, :text
  end

  def self.down
    remove_column :competitions, :long_description
  end
end

class AddTitleToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :title, :string
  end

  def self.down
    remove_column :competitions, :title
  end
end

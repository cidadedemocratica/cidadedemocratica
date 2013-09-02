class AddAuthorDescriptionToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :author_description, :text
  end

  def self.down
    remove_column :competitions, :author_description
  end
end

class ChangeShortDescriptionToString < ActiveRecord::Migration
  def self.up
    change_column :competitions, :short_description, :string
  end

  def self.down
    change_column :competitions, :short_description, :text
  end
end

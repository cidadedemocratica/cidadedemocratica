class ChangeColumnDescriptionInCompetitionsToText < ActiveRecord::Migration
  def self.up
    change_column :competitions, :description, :text
  end

  def self.down
    change_column :competitions, :description, :string
  end
end

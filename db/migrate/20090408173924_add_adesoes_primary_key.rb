class AddAdesoesPrimaryKey < ActiveRecord::Migration
  def self.up
    add_column :adesoes, :id, :primary_key
  end

  def self.down
    remove_column :adesoes, :id
  end
end

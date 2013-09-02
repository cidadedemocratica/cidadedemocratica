class AddImageToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :image, :string
  end

  def self.down
    remove_column :competitions, :image
  end
end

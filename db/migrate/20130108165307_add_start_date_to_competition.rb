class AddStartDateToCompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :start_date, :date
  end

  def self.down
    remove_column :competitions, :start_date
  end
end

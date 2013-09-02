class AddCompetitionIdToTopicos < ActiveRecord::Migration
  def self.up
    add_column :topicos, :competition_id, :integer
  end

  def self.down
    remove_column :topicos, :competition_id
  end
end

class AddLocalToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :local_id, :integer
  end
end

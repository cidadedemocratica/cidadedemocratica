class CreateCompetitionPrizes < ActiveRecord::Migration
  def change
    create_table :competition_prizes do |t|
      t.string :name
      t.text :description

      t.integer :competition_id
      t.integer :offerer_id
      t.integer :winning_topic_id

      t.timestamps
    end
  end
end

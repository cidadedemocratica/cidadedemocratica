class CreateJoiningTopics < ActiveRecord::Migration
  def change
    create_table :joining_topics do |t|
      t.integer :topico_id
      t.integer :topico_joined_id
      t.integer :current_phase_cd
      t.string :title
      t.text :description
      t.text :observation

      t.timestamps
    end
  end
end

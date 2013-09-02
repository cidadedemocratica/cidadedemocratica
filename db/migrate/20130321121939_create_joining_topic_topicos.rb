class CreateJoiningTopicTopicos < ActiveRecord::Migration
  def change
    create_table :joining_topic_topicos do |t|
      t.integer :joining_topic_id
      t.integer :topico_id
      t.string :kind

      t.timestamps
    end

    add_index :joining_topic_topicos, :joining_topic_id
    add_index :joining_topic_topicos, :topico_id
  end
end

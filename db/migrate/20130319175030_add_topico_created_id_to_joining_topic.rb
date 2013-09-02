class AddTopicoCreatedIdToJoiningTopic < ActiveRecord::Migration
  def change
    add_column :joining_topics, :topico_created_id, :integer
    add_index :joining_topics, :topico_created_id
  end
end

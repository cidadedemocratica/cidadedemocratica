class RemoveTopicosFromJoiningTopic < ActiveRecord::Migration
  def up
    remove_column :joining_topics, :topico_id
    remove_column :joining_topics, :topico_joined_id
    remove_column :joining_topics, :topico_created_id
  end

  def down
    add_column :joining_topics, :topico_id, :integer
    add_column :joining_topics, :topico_joined_id, :integer
    add_column :joining_topics, :topico_created_id, :integer
  end
end

class ChangeJoiningTopics < ActiveRecord::Migration
  def up
    add_column :joining_topics, :user_id, :integer
    add_index :joining_topics, :user_id
    add_index :joining_topics, :topico_id
    add_index :joining_topics, :topico_joined_id
  end

  def down
    remove_column :joining_topics, :user_id
    remove_index :joining_topics, :column => :user_id
    remove_index :joining_topics, :column => :topico_id
    remove_index :joining_topics, :column => :topico_joined_id
  end
end

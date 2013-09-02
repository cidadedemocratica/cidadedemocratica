class AddAuthorIdToJoiningTopic < ActiveRecord::Migration
  def change
    add_column :joining_topics, :author_id, :integer
  end
end

class AddCommentsNewIndex < ActiveRecord::Migration
  def up
    add_index :comments, [:id, :commentable_type, :commentable_id]
  end

  def down
    remove_index :comments, :column => [:id, :commentable_type, :commentable_id]
  end
end

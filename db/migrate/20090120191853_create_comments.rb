class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.integer :commentable_id, :default => 0
      t.string :commentable_type, :limit => 15, :default => ""
      t.text :body, :default => ""
      t.integer :user_id, :default => 0, :null => false
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt

      # Nossos campos:
      t.string :tipo, :limit => 20, :default => ""

      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, :commentable_id
  end

  def self.down
    drop_table :comments

    # remove_index :comments, :user_id
    # remove_index :comments, :commentable_id
  end
end
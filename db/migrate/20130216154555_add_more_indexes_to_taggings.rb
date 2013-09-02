class AddMoreIndexesToTaggings < ActiveRecord::Migration
  def self.up
    add_index :taggings, [:taggable_id, :taggable_type, :tag_id, :context], :name => "index_taggings_on_keys"
  rescue 
    # already applied manually to production, so swallow error if index already exist
  end

  def self.down
    remove_index :taggings, :name => "index_taggings_on_keys"
  end
end

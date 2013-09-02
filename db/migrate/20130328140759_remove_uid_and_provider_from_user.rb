class RemoveUidAndProviderFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :provider
    remove_column :users, :uid
  end

  def down
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end

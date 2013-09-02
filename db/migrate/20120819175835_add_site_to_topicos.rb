class AddSiteToTopicos < ActiveRecord::Migration
  def self.up
    add_column :topicos, :site, :string
  end

  def self.down
    remove_column :topicos, :site
  end
end

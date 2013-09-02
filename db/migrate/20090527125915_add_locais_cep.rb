class AddLocaisCep < ActiveRecord::Migration
  def self.up
    add_column :locais, :cep, :string, :limit => 10
  end

  def self.down
    remove_column :locais, :cep
  end
end

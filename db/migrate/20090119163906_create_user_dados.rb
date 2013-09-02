class CreateUserDados < ActiveRecord::Migration
  def self.up
    create_table "user_dados", :force => true do |t|
      t.column :user_id,                  :integer, :null => false
      t.column :nome,                     :string, :limit => 100
      t.column :fone,                     :string, :limit => 20
      t.column :email_de_contato,         :string, :limit => 60
      t.column :site_url,                 :string
      t.column :descricao,                :text
      t.column :sexo,                     :string, :limit => 1, :default => ''
      t.column :aniversario,              :date
      t.column :fax,                      :string, :limit => 20
      
      t.timestamps
    end
    add_index :user_dados, :user_id, :unique => true
    add_index :user_dados, :nome
  end

  def self.down
    drop_table "user_dados"
  end
end

class CriarHistoricoDeLogins < ActiveRecord::Migration
  def self.up
    create_table :historico_de_logins, :force => true do |t|
      t.integer  :user_id
      t.datetime :created_at
      t.string   :ip
    end

    add_index :historico_de_logins, :user_id
    add_index :historico_de_logins, :created_at
  end

  def self.down
    drop_table :historico_de_logins
  end
end

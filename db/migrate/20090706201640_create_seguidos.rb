class CreateSeguidos < ActiveRecord::Migration
  def self.up
    # N usuáris seguem com N com topicos
    create_table "seguidos", :force => true do |t|
      t.column :topico_id,                :integer, :null => false
      t.column :user_id,                  :integer, :null => false
      t.timestamps
    end
    add_index :seguidos, [:user_id, :topico_id], :unique => true
  end

  def self.down
    drop_table "seguidos"
  end
end

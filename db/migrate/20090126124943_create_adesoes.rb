class CreateAdesoes < ActiveRecord::Migration
  def self.up
    # N usuáris aderem/se solidarizam com N com topicos
    create_table "adesoes", :force => true, :id => false do |t|
      t.column :topico_id,                :integer, :null => false
      t.column :user_id,                  :integer, :null => false
      t.timestamps
    end
    add_index :adesoes, [:topico_id, :user_id], :unique => true
  end

  def self.down
    drop_table "adesoes"
    #remove_index :adesoes, [:topico_id, :user_id]
  end
end

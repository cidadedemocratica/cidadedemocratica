class CreateTopicos < ActiveRecord::Migration
  def self.up
    create_table "topicos", :force => true do |t|
      t.column :type,                     :string, :limit => 20
      t.column :user_id,                  :integer, :null => false
      t.column :titulo,                   :string
      t.column :descricao,                :text
      t.column :complementar,             :text
      t.column :parent_id,                :integer
      t.column :slug,                     :string

      t.timestamps
    end
    add_index :topicos, :user_id
    add_index :topicos, :type
    add_index :topicos, :parent_id
    add_index :topicos, :slug

    # N pra N com temas
    create_table "temas_topicos", :force => true, :id => false do |t|
      t.column :tema_id,                  :integer, :null => false
      t.column :topico_id,                :integer, :null => false
    end
    add_index :temas_topicos, [:topico_id, :tema_id], :unique => true
    
  end

  def self.down
    drop_table "topicos"
    drop_table "temas_topicos"
    
    #remove_index :topicos, :user_id
    #remove_index :topicos, :type
    #remove_index :topicos, :parent_id
    #remove_index :temas_topicos, [:topico_id, :tema_id]
  end
end

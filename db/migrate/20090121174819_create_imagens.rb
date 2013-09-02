class CreateImagens < ActiveRecord::Migration
  def self.up
    create_table :imagens, :force => true do |t|
      t.references :responsavel, :polymorphic => true

      t.integer    :size
      t.string     :content_type
      t.string     :filename

      # Para imagens.
      t.integer    :height
      t.integer    :width

      # Para thumbnails.
      t.integer    :parent_id
      t.string     :thumbnail

      # Para ordenação.
      t.integer    :position
      t.string     :legenda

      t.timestamps
    end
  end

  def self.down
    drop_table :imagens
  end
end
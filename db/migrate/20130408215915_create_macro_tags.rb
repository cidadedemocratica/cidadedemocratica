class CreateMacroTags < ActiveRecord::Migration
  def change
    create_table :macro_tags do |t|
      t.string :title

      t.timestamps
    end
  end
end

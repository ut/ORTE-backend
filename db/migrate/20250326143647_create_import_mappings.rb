class CreateImportMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :import_mappings do |t|
      t.string :name
      t.json :mapping

      t.timestamps
    end
  end
end

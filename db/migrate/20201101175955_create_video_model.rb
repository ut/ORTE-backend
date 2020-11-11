class CreateVideoModel < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :licence
      t.text :source
      t.string :creator
      t.references :place, foreign_key: true
      t.string :alt
      t.string :caption
      t.integer :sorting
      t.boolean :preview

      t.timestamps
    end
  end
end

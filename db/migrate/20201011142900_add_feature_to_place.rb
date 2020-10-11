class AddFeatureToPlace < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :featured, :boolean

  end
end

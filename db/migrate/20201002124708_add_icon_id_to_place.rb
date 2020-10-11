class AddIconIdToPlace < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :icon_id, :integer
  end
end

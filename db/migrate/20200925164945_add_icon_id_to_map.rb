class AddIconIdToMap < ActiveRecord::Migration[5.2]
  def change
    add_column :maps, :iconset_id, :integer
  end
end

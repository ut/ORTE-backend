class AddSourcesToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :sources, :text
  end
end

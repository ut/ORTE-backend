class AddGeoJsonToLayers < ActiveRecord::Migration[6.1]
  def change
    add_column :layers, :geojson, :json
  end
end

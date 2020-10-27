class AddAltBasemapUrlToMaps < ActiveRecord::Migration[5.2]
  def change
    add_column :maps, :basemap_url, :string
  end
end

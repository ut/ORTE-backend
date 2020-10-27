class AddAltBasemapAttrToMaps < ActiveRecord::Migration[5.2]
  def change
    add_column :maps, :basemap_attribution, :string
  end
end

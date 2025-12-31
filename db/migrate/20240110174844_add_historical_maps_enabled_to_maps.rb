class AddHistoricalMapsEnabledToMaps < ActiveRecord::Migration[6.1]
  def change
    add_column :maps, :enable_historical_maps, :boolean, :default => false
  end
end

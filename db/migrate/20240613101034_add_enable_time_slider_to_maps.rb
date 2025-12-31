class AddEnableTimeSliderToMaps < ActiveRecord::Migration[6.1]
  def change
    add_column :maps, :enable_time_slider, :boolean, :default => false
  end
end

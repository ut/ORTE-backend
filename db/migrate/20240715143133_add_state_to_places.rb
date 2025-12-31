class AddStateToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :state, :string    
  end
end

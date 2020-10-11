class RemoveImageFromIconsetAndIcon < ActiveRecord::Migration[5.2]
  def change
    remove_column :iconsets, :image, :string
    remove_column :icons, :image, :string
  end
end

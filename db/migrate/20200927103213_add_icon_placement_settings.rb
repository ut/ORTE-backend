class AddIconPlacementSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :iconsets, :icon_anchor, :string
    add_column :iconsets, :icon_size, :string
    add_column :iconsets, :popup_anchor, :string
    add_column :iconsets, :class_name, :string
  end
end

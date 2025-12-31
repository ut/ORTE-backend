class ConvertSessionDataToLongText < ActiveRecord::Migration[6.1]
  def up
    change_column :sessions, :data, :longtext
  end

  def down
    change_column :sessions, :data, :text
  end
end

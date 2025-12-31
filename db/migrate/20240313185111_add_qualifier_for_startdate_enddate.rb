class AddQualifierForStartdateEnddate < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :startdate_qualifier, :string
    add_column :places, :enddate_qualifier, :string
  end
end

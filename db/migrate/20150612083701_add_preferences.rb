class AddPreferences < ActiveRecord::Migration
  def up
    create_table :preferences do |t|
      t.text :name
      t.text :value
      t.timestamps
    end
  end

  def down
    drop_table :preferences
  end
end

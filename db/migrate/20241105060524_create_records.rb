class CreateRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :records do |t|
      t.string :label
      t.text :description

      t.timestamps
    end
  end
end

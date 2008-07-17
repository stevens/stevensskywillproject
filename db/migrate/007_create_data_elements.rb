class CreateDataElements < ActiveRecord::Migration
  def self.up
    create_table :data_elements do |t|
      t.string :code
      t.string :name
      t.string :category
      t.string :language
      t.text :remark

      t.timestamps
    end
  end

  def self.down
    drop_table :data_elements
  end
end

class CreateCodes < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.references :data_element
      t.string :code
      t.string :name
      t.string :language
      t.text :remark

      t.timestamps
    end
  end

  def self.down
    drop_table :codes
  end
end

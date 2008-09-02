class CreateCodes < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.string :codeable_type
      t.string :code
      t.string :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :codes
  end
end

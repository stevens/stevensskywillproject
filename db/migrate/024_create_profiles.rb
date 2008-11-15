class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.references :user
      t.string :gender
      t.string :gender_show_type
      t.datetime :birthday
      t.string :birthday_show_type
      t.string :location
      t.string :hometown
      t.string :blog
      t.text :intro
      t.string :privacy

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end

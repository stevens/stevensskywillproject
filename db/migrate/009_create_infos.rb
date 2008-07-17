class CreateInfos < ActiveRecord::Migration
  def self.up
    create_table :infos do |t|
      t.string :code
      t.string :text
      t.string :category
      t.string :language
      t.text :remark

      t.timestamps
    end
  end

  def self.down
    drop_table :infos
  end
end

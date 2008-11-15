class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.references :user
      t.string :storyable_type
      t.integer :storyable_id
      t.string :story_type

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end

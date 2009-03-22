class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.references :user
			t.string :scoreable_type
			t.integer :scoreable_id
      t.string :taste
      t.string :shape
      t.string :creative
      t.string :nutrition
      t.string :cost_performance

      t.timestamps
    end

    add_index :scores, [:user_id], :name => 'fk_user'
    add_index :scores, [:scoreable_type, :scoreable_id], :name => 'i_scoreable'
    add_index :scores, [:user_id, :scoreable_type, :scoreable_id], :name => 'i_user_scoreable'
  end

  def self.down
    drop_table :scores
  end
end

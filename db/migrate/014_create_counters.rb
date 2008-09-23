class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
	    t.string :countable_type
	    t.integer :countable_id
	    t.integer :total_view_count
	    t.integer :user_view_count

      t.timestamps
    end
  end

  def self.down
    drop_table :counters
  end
end

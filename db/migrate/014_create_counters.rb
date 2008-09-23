class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
	    t.string :countable_type
	    t.integer :countable_id
	    t.integer :view_count

      t.timestamps
    end
  end

  def self.down
    drop_table :counters
  end
end

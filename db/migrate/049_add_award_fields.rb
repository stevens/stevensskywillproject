class AddAwardFields < ActiveRecord::Migration
  def self.up
		add_column :awards, :decide_mode, :string #评选方式(票选/直选/抽选)
		add_column :awards, :award_type, :string #奖项类型(主奖项/非主奖项)
  end

  def self.down
  	remove_column :awards, :decide_mode
  	add_column :awards, :award_type
  end
end

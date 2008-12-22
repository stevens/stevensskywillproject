class AddAwardFields < ActiveRecord::Migration
  def self.up
  	add_column :awards, :awardable_type, :string #获奖对象类型（如作品将、投票奖、评论奖等）
  	add_column :awards, :winners_count, :integer
  end

  def self.down
  	remove_column :awards, :awardable_type
  	remove_column :awards, :winners_count
  end
end

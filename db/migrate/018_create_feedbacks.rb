class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.references :user
      t.string :category
      t.string :title
      t.text :body
			
      t.timestamps
    end
    
    add_index :feedbacks, [:user_id], :name => 'fk_user'
    add_index :feedbacks, [:category], :name => 'i_category'
    add_index :feedbacks, [:user_id, :category], :name => 'i_user_category'
  end

  def self.down
    drop_table :feedbacks
  end
end

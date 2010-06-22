class CreateUsermessages < ActiveRecord::Migration
  def self.up
    create_table :usermessages do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.references :message
      t.integer :sender_status
      t.integer :recipient_status
      t.integer :ifread

      t.timestamps
    end
  end

  def self.down
    drop_table :usermessages
  end
end

class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
			t.references :user
			t.references :contactor
			t.string :contact_type
			t.string :status
			t.datetime :accepted_at
			
      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end

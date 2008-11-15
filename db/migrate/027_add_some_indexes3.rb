class AddSomeIndexes3 < ActiveRecord::Migration
  def self.up
  	add_index :contacts, [:user_id], :name => 'fk_user'
  	add_index :contacts, [:contactor_id], :name => 'fk_contactor'
  	add_index :contacts, [:user_id, :contactor_id], :name => 'i_user_contactor'
		add_index :contacts, [:user_id, :contact_type], :name => 'i_user_contact_type'
		add_index :contacts, [:contactor_id, :contact_type], :name => 'i_contactor_contact_type'
		add_index :contacts, [:user_id, :contactor_id, :contact_type], :name => 'i_user_contactor_contact_type'
		
		add_index :profiles, [:user_id], :name => 'fk_user'
		
		add_index :stories, [:user_id], :name => 'fk_user'
		add_index :stories, [:storyable_type, :storyable_id], :name => 'pi_storyable'
		add_index :stories, [:storyable_type], :name => 'pi_storyable_type'
		add_index :stories, [:user_id, :storyable_type, :storyable_id], :name => 'i_user_storyable'
		add_index :stories, [:user_id, :storyable_type], :name => 'i_user_storyable_type'
  end

  def self.down
  	remove_index :contacts, :name => 'fk_user'
  	remove_index :contacts, :name => 'fk_contactor'
  	remove_index :contacts, :name => 'i_user_contactor'
		remove_index :contacts, :name => 'i_user_contact_type'
		remove_index :contacts, :name => 'i_contactor_contact_type'
		remove_index :contacts, :name => 'i_user_contactor_contact_type'
		
		remove_index :profiles, :name => 'fk_user'
		
		remove_index :stories, :name => 'fk_user'
		remove_index :stories, :name => 'pi_storyable'
		remove_index :stories, :name => 'pi_storyable_type'
		remove_index :stories, :name => 'i_user_storyable'
		remove_index :stories, :name => 'i_user_storyable_type'
  end
end

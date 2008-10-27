class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.references :user
      t.string :favorable_type
      t.integer :favorable_id
      t.string :status
      t.text :note

      t.timestamps
    end
    
    add_index :favorites, [:user_id], :name => 'fk_user'
    add_index :favorites, [:favorable_type], :name => 'pi_favorable_type'
    add_index :favorites, [:user_id, :favorable_type], :name => 'i_user_favorable_type'
    add_index :favorites, [:favorable_type, :favorable_id], :name => 'pi_favorable'
    add_index :favorites, [:user_id, :favorable_type, :favorable_id], :name => 'i_user_favorable'
    add_index :favorites, [:favorable_type, :status], :name => 'i_favorable_type_status'
    add_index :favorites, [:user_id, :favorable_type, :status], :name => 'i_user_favorable_type_status'
  end

  def self.down
    drop_table :favorites
  end
end

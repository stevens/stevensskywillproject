class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.references :user
      t.string :title
      t.string :subject
      t.string :entriable_type
      t.text :description
      t.string :organiger_type
      t.integer :organiger_id
      
      t.integer :cover_photo_id
      
      t.datetime :start_at
      t.datetime :end_at
      
      t.datetime :voting_start_at
      t.datetime :voting_end_at
      
      t.integer :entries_per_player #每个参赛人能有几个参赛作品
      t.integer :entries_per_voter #每个投票人可以给几个参赛作品投票
      t.integer :votes_per_entry #每个投票人可以给每个参赛作品投几票
      t.integer :votes_lower_limit #每个参赛作品至少需要几个投票人投票才能参与排名
      t.string :voting_type #是否采用实名投票
      t.string :self_vote #是否可以自己投自己

      t.text :any_else
      t.string :status
      t.string :privacy
      
      t.integer :photos_count
      t.integer :reviews_count
      t.integer :favorites_count
      t.integer :entries_count
      t.integer :awards_count
      
      t.timestamps
    end
    
    add_index :matches, [:user_id], :name => 'fk_user'
    add_index :matches, [:entriable_type], :name => 'i_entriable_type'
    add_index :matches, [:organiger_type], :name => 'i_organiger_type'
    add_index :matches, [:organiger_type, :organiger_id], :name => 'i_organiger'
  end

  def self.down
    drop_table :matches
  end
end

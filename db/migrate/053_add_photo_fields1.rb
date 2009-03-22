class AddPhotoFields1 < ActiveRecord::Migration
  def self.up
    add_column :photos, :related_subitem_type, :string
    add_column :photos, :related_subitem_id, :integer

  	add_index :photos, [:related_subitem_type, :related_subitem_id], :name => 'i_subitem'
    add_index :photos, [:photoable_type, :photoable_id, :related_subitem_type], :name => 'i_photoable_subitem_type'
  	add_index :photos, [:photoable_type, :photoable_id, :related_subitem_type, :related_subitem_id], :name => 'i_photoable_subitem'
  end

  def self.down
    remove_column :photos, :related_subitem_type
    remove_column :photos, :related_subitem_id

    remove_index :photos, :name => 'i_subitem'
    remove_index :photos, :name => 'i_photoable_subitem_type'
    remove_index :photos, :name => 'i_photoable_subitem'
  end
end

class CreateWines < ActiveRecord::Migration
  def self.up
    create_table :wines do |t|
      t.references :user
      t.string :title
      t.string :common_title
      t.text :description
      t.string :wine_type #鍝佺
      t.string :grape_type #钁¤悇绉嶇被
      t.string :grape_tree_age #钁¤悇鏍戝勾榫�      t.string :soil_type #鍦熷￥绉嶇被
      t.string :plant_amount #绉嶆鏁伴噺
      t.string :implantation_mode #鍦熷湴鍩规鏂瑰紡
      t.string :output #浜ч噺
      t.string :ferment_mode #鍙戦叺鏂瑰紡
      t.string :color #鑹叉辰
      t.string :smell #姘斿懗
      t.string :storage_temperature #淇濆瓨娓╁害
      t.string :food_pairing #椋熺敤寤鸿
      t.string :alcohol_level #閰掔簿鍚噺
      t.string :pack_type #鍖呰绫诲瀷
      t.string :volume #瀹归噺
      t.string :country #鍘熶骇鍥�      t.string :region #浜у尯
      t.string :vintage #骞翠唤
      
      t.integer :cover_photo_id #

      t.string :image_file_path #临时用
      t.string :image_filename #临时用

      t.timestamps
    end

    add_index :wines, [:user_id], :name => 'fk_user'
  end

  def self.down
    drop_table :wines
  end
end

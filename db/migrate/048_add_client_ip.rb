class AddClientIp < ActiveRecord::Migration
  def self.up
  	add_column :users, :client_ip, :string
  	add_column :profiles, :client_ip, :string
  	add_column :recipes, :client_ip, :string
  	add_column :reviews, :client_ip, :string
  	add_column :photos, :client_ip, :string
  	add_column :matches, :client_ip, :string
  	add_column :feedbacks, :client_ip, :string
  end

  def self.down
  	remove_column :users, :client_ip
  	remove_column :profiles, :client_ip
  	remove_column :recipes, :client_ip
  	remove_column :reviews, :client_ip
  	remove_column :photos, :client_ip
  	remove_column :matches, :client_ip
  	remove_column :feedbacks, :client_ip
  end
end

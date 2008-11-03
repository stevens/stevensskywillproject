require 'net/http'
require 'uri'

class HomepageObserver < ActiveRecord::Observer
	observe Homepage
	
	include ActionController::UrlWriter
	default_url_options[:host] = SITE_DOMAIN_EN
	
	def after_create(homepage)
		Net::HTTP.get('www.google.com' ,
									'/ping?sitemap=' + URI.escape(sitemap_url))
	end
	
	def after_destroy(homepage)
		Net::HTTP.get('www.google.com' ,
									'/ping?sitemap=' + URI.escape(sitemap_url))
	end
	
end
xml.instruct!
xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
	@pages.each do |page|
		xml.url do
			# xml.loc homepage_url(page)
			xml.loc "#{root_url}#{page.content}"
			xml.lastmod page.updated_at.xmlschema
		end
	end
end
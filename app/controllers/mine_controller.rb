class MineController < ApplicationController
	
	before_filter :protect
	
  def index
		info = sysinfo('300002', '', {:title => I_CN}, '', {:type => SITE_NAME_CN})
		set_page_title(info)
  end

	private
	
	def set_page_title(info)
		@page_title = page_title(info, '')
	end

end

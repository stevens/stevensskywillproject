class MineController < ApplicationController
	
	before_filter :protect
	
  def index
	 	info = "我的#{SITE_NAME_CN}"
		set_page_title(info)
  end

end

class WinesController < ApplicationController

  def pop_content
  	respond_to do |format|
			format.js do
        @wine = Wine.find_by_id(params[:id])
				render :update do |page|
          page.replace_html "overlay",
                            :partial => "wines/wine_overlay",
                            :locals => { :wine => @wine }
					page.show "overlay"
				end
			end
  	end
  end
  
end

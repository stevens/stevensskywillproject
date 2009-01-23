class RatingsController < ApplicationController

  before_filter :protect
  
  def new
		redirect_to @parent_obj if @parent_obj
  end
       
  def rate
  	load_rateable
  	
  	new_rating_value = params[:id]
  	
  	if my_rating = user_rating(@current_user, @rateable)
  		my_rating.rating = new_rating_value
  	else
  		my_rating = @rateable.ratings.build(:user_id => @current_user.id, :rating => new_rating_value)
  	end
  	
  	if my_rating.save
  		after_rate_ok
  	end
  	
  	# if my_rating.save
	  #   render :update do |page|   
	  #     page.replace_html "#{@rateable_type.downcase}_#{@rateable_id}_rating", 
	  #     									:partial => "/ratings/rate", 
	  #     									:locals => {:rateable => @rateable}   
	  #   end 		
  	# else
  	# 	flash[:notice] = "#{SORRY_CN}, 出现#{ERROR_CN}，请重新#{RATE_CN}!"
  	# end   
  end 
  
  private
  
  def load_rateable
  	@rateable = model_for(params[:rateable_type]).find(params[:rateable_id])
  	@rateable_type = type_for(@rateable)
  	@rateable_id = @rateable.id
  end
  
  def after_rate_ok
  	respond_to do |format|
			format.js do
				render :update do |page|
					page.replace_html "#{@rateable_type.downcase}_rating", 
														:partial => 'ratings/item_rating', 
														:locals => { :item => @rateable }
					page.replace_html "my_#{@rateable_type.downcase}_rating",
														:partial => 'ratings/my_rating', 
														:locals => { :item => @rateable }
				end
			end
		end
  end
  
end

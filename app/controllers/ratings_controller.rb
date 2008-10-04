class RatingsController < ApplicationController

  before_filter :protect
  
  def new
		redirect_to @parent_obj if @parent_obj
  end
       
  def rate
  	load_rateable
  	
  	new_rating_value = params[:id].to_i
  	
  	if my_rating = user_rating(@current_user, @rateable)
  		my_rating.rating = new_rating_value
  	else
  		my_rating = @rateable.ratings.build(:user_id => @current_user.id, :rating => new_rating_value)
  	end
  	
  	if my_rating.save
	    render :update do |page|   
	      page.replace_html "#{@rateable_type.downcase}_#{@rateable_id}_rating", 
	      									:partial => "rate", 
	      									:locals => {:rateable => @rateable}   
	    end 		
  	else
  		flash[:notice] = "#{SORRY_CN}, 出现#{ERROR_CN}，请重新#{RATE_CN}!"
  	end   
  end 
  
  private
  
  def load_rateable
  	@rateable = model_for(params[:rateable_type]).find(params[:rateable_id])
  	@rateable_type = type_for(@rateable)
  	@rateable_id = @rateable.id
  end
  
end

class RatingsController < ApplicationController

  before_filter :protect
       
  def rate_it
  	load_rateable
  	
  	new_rating_value = params[:id].to_i
  	
  	if my_rating = user_rating(@current_user, @rateable)
  		my_rating.rating = new_rating_value
  	else
  		my_rating = @rateable.ratings.build(:user_id => @current_user.id, :rating => new_rating_value)
  	end
  	
  	if my_rating.save
	    render :update do |page|   
	      page.replace_html "#{@rateable_type}_rating", 
	      									:partial => "rate", 
	      									:locals => {:ratings_count => @rateable.ratings.size, 
	       															:average_rating_value => average_rating_value(@rateable), 
	      															:my_rating_value => new_rating_value, 
	      															:rateable_type => @rateable_type, 
	      															:rateable_id => @rateable_id}   
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

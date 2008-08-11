class RatingsController < ApplicationController

  before_filter :protect
       
  def rate
  	load_rateable
  	
  	new_rating = params[:id].to_i
  	
  	my_rating = @current_user.ratings.find(:first, :conditions => {:rateable_type => @rateable_type, :rateable_id => @rateable_id})
  	
  	if my_rating
  		my_rating.rating = new_rating  
    else
    	my_rating = @current_user.ratings.build(:rateable_type => @rateable_type, :rateable_id => @rateable_id, :rating => new_rating)
    end
    
   	if my_rating.save
	  	total_rating = Rating.average('rating', :conditions => {:rateable_type => @rateable_type, :rateable_id => @rateable_id})
	  	ratings_count = Rating.count(:conditions => {:rateable_type => @rateable_type, :rateable_id => @rateable_id})
  		
	    render :update do |page|   
	      page.replace_html "#{@rateable_type}_rating", 
	      									:partial => "rate", 
	      									:locals => {:ratings_count => ratings_count, 
	      															:total_rating => total_rating, 
	      															:current_rating => new_rating, 
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

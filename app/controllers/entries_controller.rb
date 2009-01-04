class EntriesController < ApplicationController
	
  before_filter :protect, :except => [:index, :show]
	before_filter :clear_location_unless_logged_in, :only => [:index, :show]
	# before_filter :load_current_filter, :only => [ ]
	
	def new
		
	end
	
end

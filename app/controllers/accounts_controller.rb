class AccountsController < ApplicationController
	
	before_filter :protect
	before_filter :load_account
		
	def edit
	 	info = "#{CHANGE_CN}#{name_for(params[:id])}"
		
		set_page_title(info)
		set_block_title(info)
	end
	
	def update
	
	end

	private

	def load_account
		@account = @current_user
	end

end

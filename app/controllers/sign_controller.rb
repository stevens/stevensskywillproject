class SignController < ApplicationController

  def authenticate
    self.logged_in_keeper = Keeper.authenticate(params[:keeper][:username],
      params[:keeper][:password])
    if is_keeper_logged_in?
      if is_admin_logged_in?
        redirect_to :controller=>'keepers', :action=>'index'
      else
        flash[:notice] = "I'm sorry; You do not have the permission to do that."
        redirect_to :action => 'login'
      end
    else
      flash[:notice] = "I'm sorry; either your username or password was incorrect."
        redirect_to :action => 'login'
    end
    
  end
  def logout
    session[:keeper] = nil
    flash[:notice] = "You have been logged out."
    redirect_to :action => 'login'
  end
end

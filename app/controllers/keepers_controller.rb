class KeepersController < ApplicationController
  include LoginSystem
  #before_filter :keeper_login_required, :except => [:new,:create]
  before_filter :check_administrator_role, :only => [:index,:destroy,:enable]

  def index
    @keepers = Keeper.find(:all)
    @users = User.find(:all)
  end
  def show
    @keeper = Keeper.find(params[:id])
  end
  def show_by_username
    @keeper = Keeper.find_by_username(params[:username])
    render :action => 'show'
  end
  def new
    @keeper = Keeper.new
  end
  def create
    @keeper = Keeper.new(params[:keeper])
    if @keeper.save
      self.logged_in_keeper = @keeper
      flash[:notice] = "Your account has been created."
      redirect_to :action=>'index'
    else
      render :action => 'new'
    end
  end
  def edit
    @keeper = logged_in_keeper
  end
  def update
    @keeper = Keeper.find(logged_in_keeper)
    if @keeper.update_attributes(params[:keeper])
      flash[:notice] = "Keeper updated"
      redirect_to :action => 'show', :id => logged_in_keeper
    else
      render :action => 'edit'
    end
  end
  def destroy
    @keeper = Keeper.find(params[:id])
    if @keeper.update_attribute(:enabled, false)
      flash[:notice] = "Keeper disabled"
    else
      flash[:notice] = "There was a problem disabling this keeper."
    end
    redirect_to :action => 'index'
  end
  def enable
    @keeper = Keeper.find(params[:id])
    if @keeper.update_attribute(:enabled, true)
      flash[:notice] = "Keeper enabled"
    else
      flash[:notice] = "There was a problem enabling this keeper."
    end
    redirect_to :action => 'index'
  end
  def sendnewsletter
    @user = User.find(params[:id])
    Notifier.deliver_send_newsletter(@user)
    flash[:notice] = "mail has send to #{@user.login}."
    redirect_to :action => 'index'
  end
end

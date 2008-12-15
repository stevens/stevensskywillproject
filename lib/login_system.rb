module LoginSystem
  protected
  def is_keeper_logged_in?
    @logged_in_keeper = Keeper.find(session[:keeper]) if session[:keeper]
  end
  def is_admin_logged_in?
    @logged_in_keeper if is_keeper_logged_in? && @logged_in_keeper.has_role?('Administrator')
  end
  def logged_in_keeper
    return @logged_in_keeper if is_keeper_logged_in?
  end
  def logged_in_keeper=(keeper)
    if !keeper.nil?
      session[:keeper] = keeper.id
      @logged_in_keeper = keeper
    end
  end
  def keeper_login_required
    unless is_keeper_logged_in?
      flash[:notice] = "You must be logged in to do that."
      redirect_to :controller => 'sign', :action => 'login'
    end
  end
  def check_role(role)
    unless is_keeper_logged_in? && @logged_in_keeper.has_role?(role)
      flash[:notice] = "You do not have the permission to do that."
      redirect_to :controller => 'sign', :action => 'login'
    end
  end
  def check_administrator_role
    check_role('Administrator')
  end
  def self.included(base)
    base.send :helper_method, :is_keeper_logged_in?, :logged_in_keeper, :is_admin_logged_in?
  end
end

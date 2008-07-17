ActionController::Routing::Routes.draw do |map|
	map.connect 'mine/:controller', :action => 'mine'
	# map.connect ':controller/:type', :action => 'find_by'
  # map.resources :infos

  # map.resources :codes

  # map.resources :data_elements

  map.resources :users, :has_many => [:recipes, :photos, :reviews]
	
	map.resources :recipes, :has_many => [:photos, :reviews]
	
	map.resources :photos, :has_many => :reviews
	
	map.resources :reviews
	
  map.resource :session
  
  map.namespace :mine do |mine|
   	mine.resources :recipes do |recipe|
   		recipe.resources :photos 														
   	end
   	mine.resources :photos
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'site'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:id', :action => 'index'
  # map.connect ':controller/:id/:action'
  # map.connect ':namespace/:controller/:action/:id'
  
  #easier routes for restful_authentication
	map.signup '/signup', :controller => 'users', :action => 'new'
	map.login '/login', :controller => 'sessions', :action => 'new'
	map.logout '/logout', :controller => 'sessions', :action => 'destroy'
	map.activate '/activate/:id', :controller => 'users', :action => 'activate'
	map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
	map.reset_password '/reset_password', :controller => 'users', :action => 'reset_password'
end

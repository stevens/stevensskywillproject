ActionController::Routing::Routes.draw do |map|
	map.connect ':controller/overview', :action => 'overview'
	map.connect 'users/:id/overview', :controller => 'users', :action => 'overview'
	
	map.connect ':controller/search/:id', :action => 'search'	
	
	map.connect 'mine/recipes', :controller => 'recipes', :action => 'mine'
	
	map.connect 'mine/reviews', :controller => 'reviews', :action => 'mine'
	map.connect ':reviewable_type/reviews', :controller => 'reviews', :action => 'index'
	map.connect 'mine/:reviewable_type/reviews', :controller => 'reviews', :action => 'mine'
	map.connect 'users/:user_id/:reviewable_type/reviews', :controller => 'reviews', :action => 'index'
	
	map.connect 'mine/taggings', :controller => 'taggings', :action => 'mine'
	map.connect 'users/:user_id/taggings', :controller => 'taggings', :action => 'index'
	map.connect ':taggable_type/taggings', :controller => 'taggings', :action => 'index'
	map.connect ':taggable_type/taggings/:id', :controller => 'taggings', :action => 'show'
	map.connect 'mine/:taggable_type/taggings', :controller => 'taggings', :action => 'mine'
	map.connect 'users/:user_id/:taggable_type/taggings', :controller => 'taggings', :action => 'index'
	
	map.connect ':searchable_type/searching/:id', :controller => 'searching', :action => 'show'
	
	map.search '/search', :controller => 'site', :action => 'search'
	
  map.resources :users, :has_many => [:recipes, :photos, :reviews, :ratings]
	
	map.resources :recipes, :has_many => [:photos, :reviews, :ratings, :taggings, :tags]
	
	map.resources :photos, :has_many => :reviews
	
	map.resources :reviews
	
  map.resources :taggings
  
  map.resource :session
  
  
  # map.namespace :mine do |mine|
  #  	mine.resources :recipes do |recipe|
  #  		recipe.resources :photos 														
  # 	end
  # 	mine.resources :photos
  # end

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
  # map.connect ':controller/:id/:action'
  # map.connect ':namespace/:controller/:action/:id'
  
  #easier routes for restful_authentication
	map.signup '/signup', :controller => 'users', :action => 'new'
	map.login '/login', :controller => 'sessions', :action => 'new'
	map.logout '/logout', :controller => 'sessions', :action => 'destroy'
	map.activate '/activate/:id', :controller => 'users', :action => 'activate'
	map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
	map.reset_password '/reset_password/:id', :controller => 'passwords', :action => 'edit'
	
end

ActionController::Routing::Routes.draw do |map|
  
  map.resources :documents

  map.connect 'recipes/love_recipe_stats', :controller => 'recipes', :action => 'love_recipe_stats'
  map.connect 'recipes/pk_game', :controller => 'recipes', :action => 'pk_game'

	map.connect 'homepages/import', :controller => 'homepages', :action => 'import'
	map.connect ':controller/overview', :action => 'overview'
	
	map.connect 'matches/:id/profile', :controller => 'matches', :action => 'profile'
	map.connect 'mine/matches', :controller => 'matches', :action => 'mine'
	map.connect 'matches/help', :controller => 'matches', :action => 'help'

  map.connect 'matches/:match_id/entry/manage', :controller => 'entries', :action => 'manage'
	map.connect 'matches/:match_id/entry/calculate_valid_votes', :controller => 'entries', :action => 'calculate_valid_votes'

	map.connect 'users/:id/overview', :controller => 'users', :action => 'overview'
	map.connect 'users/:id/profile', :controller => 'users', :action => 'profile'

  map.connect 'users/week_stat', :controller => 'users', :action => 'week_stat'

	map.connect 'mine/contacts', :controller => 'contacts', :action => 'mine'
	map.connect 'users/:user_id/:contact_type/contacts', :controller => 'contacts', :action => 'index'

	map.connect 'mine/friends', :controller => 'contacts', :action => 'mine', :contact_type => 'friend'
	map.connect 'users/:user_id/friends', :controller => 'contacts', :action => 'index', :contact_type => 'friend'
	
	map.connect 'mine/recipes', :controller => 'recipes', :action => 'mine'

  map.connect 'mine/menus', :controller => 'menus', :action => 'mine'
	
	map.connect 'mine/reviews', :controller => 'reviews', :action => 'mine'
	map.connect ':reviewable_type/reviews', :controller => 'reviews', :action => 'index'
	map.connect 'mine/:reviewable_type/reviews', :controller => 'reviews', :action => 'mine'
	map.connect 'users/:user_id/:reviewable_type/reviews', :controller => 'reviews', :action => 'index'

	map.connect 'mine/favorites', :controller => 'favorites', :action => 'mine'
	map.connect ':favorable_type/favorites', :controller => 'favorites', :action => 'index'
	map.connect 'mine/:favorable_type/favorites', :controller => 'favorites', :action => 'mine'
	map.connect 'users/:user_id/:favorable_type/favorites', :controller => 'favorites', :action => 'index'
	
	map.connect 'mine/tags', :controller => 'taggings', :action => 'mine'
	map.connect 'users/:user_id/tags', :controller => 'taggings', :action => 'index'
	map.connect ':taggable_type/tags', :controller => 'taggings', :action => 'index'
	map.connect ':taggable_type/tags/:id', :controller => 'taggings', :action => 'show'
	map.connect 'mine/:taggable_type/tags', :controller => 'taggings', :action => 'mine'
	map.connect 'users/:user_id/:taggable_type/tags', :controller => 'taggings', :action => 'index'
	
	map.connect ':searchable_type/search/:id', :controller => 'searchings', :action => 'show'
	
	map.resources :users, 
								:has_many => [:recipes, :menus, :courses, :scores, :photos, :reviews, :ratings, :taggings, :tags, :feedbacks, :favorites, :contacts, :friends, :stories, :matches, :entries, :votes, :winners, :match_actors, :players, :admins],
								:has_one => [:profile, :counter]
	map.resources :recipes, 
								:has_many => [:photos, :reviews, :ratings, :taggings, :tags, :favorites, :entries], 
								:has_one => [:counter]
        
  map.resources :matches, 
  							:has_many => [:photos, :reviews, :taggings, :tags, :favorites, :entries, :awards, :votes, :winners, :match_actors], 
  							:has_one => [:profile, :counter]
  map.resources :entries, 
  							:has_many => [:votes, :winners], 
  							:has_one => [:counter]
  map.resources :awards, 
  							:has_many => [:photos, :reviews, :favorites, :winners]
  map.resources :winners
  map.resources :match_actors

  map.resources :menus,
                :has_many => [:courses, :photos, :reviews, :ratings, :taggings, :tags, :favorites, :entries],
                :has_one => [:counter]
  map.resources :courses,
                :has_many => [:photos, :reviews, :taggings, :tags],
                :has_one => [:score]
  map.resources :scores
	map.resources :photos, 
								:has_many => [:reviews, :taggings, :tags], 
								:has_one => [:counter]
	map.resources :reviews
	map.resources :taggings
	map.resources :searchings
	map.resources :feedbacks
	map.resources :favorites
	map.resources :homepages
	map.resources :contacts
	map.resources :profiles
	map.resources :stories
	map.resources :votes

  map.resources :wines
  
	map.resources :keepers, :member => { :enable => :put } #后台管理用
	map.resources :newsletters, :member => { :sendmails => :put } #后台管理用
  
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
  
  # easier routes for restful_authentication
	map.signup '/signup', :controller => 'users', :action => 'new'
	map.login '/login', :controller => 'sessions', :action => 'new'
	map.logout '/logout', :controller => 'sessions', :action => 'destroy'
	map.activate '/activate/:id', :controller => 'users', :action => 'activate'
	map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
	map.reset_password '/reset_password/:id', :controller => 'passwords', :action => 'edit'
	map.lost_activation '/lost_activation', :controller => 'users', :action => 'lost_activation'
	map.resend_activation '/resend_activation', :controller => 'users', :action => 'resend_activation'
	map.search '/search', :controller => 'searchings', :action => 'search'
	map.feedback '/feedback', :controller => 'feedbacks', :action => 'new'
	map.about '/about', :controller => 'site', :action => 'about'
	map.help '/help', :controller => 'site', :action => 'help'
	map.privacy '/privacy', :controller => 'site', :action => 'privacy'
	map.terms '/terms', :controller => 'site', :action => 'terms'
  map.linkus '/linkus', :controller => 'site', :action => 'linkus'
	map.sitemap 'sitemap.xml' , :controller => 'sitemap' , :action => 'sitemap'
	
	# for newsletter
	map.sendmail '/sendmail/:id', :controller => 'keepers', :action => 'sendnewsletter'

#  map.connect '*path', :controller => 'application', :action => 'rescue_errors' unless ::ActionController::Base.consider_all_requests_local
end

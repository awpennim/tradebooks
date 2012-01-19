Zoomasstextbooks::Application.routes.draw do

  get "help/buying_and_selling"

  get "help/offers"

  resources :messages

  get "sessions/new"

  resources :admins, :only => [:index] do
    member do
      delete 'delete_faq'
    end

    collection do
      get 'add_faq'
      post 'add_faq' => 'admins#create_faq'
    end
  end

  resources :users, :only => [:new, :create, :destroy, :show, :index, :update] do
    member do
      get 'home'
      get 'verify'
      post 'post_verify'
      get 'settings'
      get 'notifications'
      get 'for_sale_listings'
      get 'looking_for_listings'
      get 'recieved_offers'
      get 'sent_offers'
      post 'new_verification_token'
      get 'deals'
    end

    collection do
      get 'forgot_password'
      post 'post_forgot_password'
    end

    resources :messages, :only => [:destroy, :create, :new, :index, :show], :path_names => { :new => "compose" } do

      collection do
        get 'inbox'
	get 'outbox'
      end
    end
  end

  match "/signup", :to => "users#new"

  get "textbooks/search" 
  resources :textbooks do
    
    resources :listings, :except => [:index, :new] do
      member do
        get 'renew'
        get 'new_selling_offer'
	get 'new_buying_offer'
	get 'why_renew'
      end

      collection do
        get 'for_sale'
	get 'looking_for'
	get 'post_for_sale'
	get 'post_looking_for'
      end
    end

    resources :offers, :only => [:show, :create ] do
      member do
        post 'accept'
	delete 'reject'
	get 'counter'
	delete 'cancel'
      end
    end
  end

  resources :sessions, :only => [:new, :create, :destroy], :path_names => {:create => 'signin'}
  match '/signout', :to => 'sessions#destroy'
  match '/signin', :to => 'sessions#new'

  match "/help", :to => "info#home"
  match "/contact", :to => "info#contact"
  match "/about", :to => "info#about"
  match "/faq", :to => "info#faq"
  match "/privacy_policy", :to => "info#privacy_policy"
  get "info/under_construction"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "info#home"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

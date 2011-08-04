Personnel::Application.routes.draw do
  get "users/show"

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
  devise_for :users
  resource :user do
      get 'edit_data', :on => :member
      put 'update_data', :on => :member
      get 'display_addresses', :on => :member
      get 'display_section', :on => :member
      get 'find', :on => :collection
  end

  resources :addresses do
    get 'make_primary', :on => :member
  end
  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  namespace :admin do
    root :to => "users#index"
    resources :admins, :departments

    resources :addresses do
      get 'make_primary', :on => :member
    end

    resources :users do
      get 'delivery', :on => :collection
      get 'edit_data', :on => :member
      put 'update_data', :on => :member
      get 'display_addresses', :on => :member
      get 'display_section', :on => :member
    end
  end
  devise_for :admins
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

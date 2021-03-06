Personnel::Application.routes.draw do

  resources :taxi_routes, only: [:index, :create, :destroy]

  #get "users/show"

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
  #       get 'recent', on: :collection
  #     end
  #   end
  devise_for :users, :controllers => { :registrations => "user_registrations" }
  resource :user do
      get :delivery, on: :collection
      get :edit_data, on: :member
      put :update_data, on: :member
      put :update_crop, on: :member
      get :display_addresses, on: :member
      get :display_section, on: :member
      get :notify_address, on: :collection
      get :notify_cell, on: :collection
      get :crop, on: :member
      get :find, on: :collection
      get :list, on: :collection
      put :send_notify_address, on: :collection
      put :send_notify_cell, on: :collection
  end

  resources :users do
    get :view, on: :member
    get :by_department, on: :collection
  end

  resources :addresses do
    get :make_primary, on: :member
    get :map, on: :member
    put :update_map, on: :member
  end

  resources :shifts do
    get :close_old, on: :collection
    get :check, on: :collection
    get :check_department_for_identifier, on: :member
    get :check_fired_permissions, on: :collection
  end
  resource :schedule do
    post :update_cell, on: :collection
    post :toggle_exclude, on: :collection
  end
  resources :vacation_requests
  resources :events do
    get :start_shift, on: :collection
    get :end_shift, on: :collection
    post :create_shift, on: :collection
    get :available_shift_numbers, on: :collection
    get :new_late_coming, on: :collection
    post :create_late_coming, on: :collection
    get :processed_by_person, on: :collection
    get :vacations, on: :collection
    get :new_self_score, on: :collection
    get :new_shift_leader_score, on: :collection
    post :create_self_score, on: :collection
    post :create_shift_leader_score, on: :collection
    get :list, on: :collection
  end
  resources :user_vehicles
  resources :late_comings
  resources :birthdays
  devise_for :admins, :controllers => { :registrations => "admin_registrations" }
  namespace :admin do
    root :to => "users#index"
    resources :departments, :categories, :schedule_statuses, :schedule_shifts, :permissions, :logs
    resources :late_comings do
      put :release, on: :collection
    end
    resources :admins do
      get :settings_edit, on: :collection
      put :settings_update, on: :collection
    end
    resource :schedule do
      get :show_users, on: :member
    end
    resources :schedule_cells do
      put :mass_update, on: :collection
      get :change, on: :collection
      get :batch_new, on: :collection
      put :batch_update, on: :collection
    end
    resources :shifts do
      get :available_shift_numbers, on: :collection
      get :missed, on: :collection
    end
    resources :events do
      get :processed_total, on: :collection
      get :processed_by_person, on: :collection
      get :vacations, on: :collection
      get :processed_by_day_of_week, on: :collection
      get :self_scores, on: :collection
      get :self_scores_grouped, on: :collection
      get :shift_leader_scores, on: :collection
      get :shift_leader_scores_grouped, on: :collection
    end
    resources :schedule_templates do
      post :set_visibility, on: :member
      get :select_users, on: :member
      put :update_editable_users, on: :member
      get :check_day, on: :member
      get :check_day_detailed, on: :member
      get :check_month, on: :member
      get :default_norms, on: :member
      get :user_norms, on: :member
      post :update_default_norms, on: :member
      post :update_user_norms, on: :member
      get :check_shift_interval, on: :member
    end

    resources :addresses do
      get :make_primary, on: :member
      get :map, on: :member
      put :update_map, on: :member
    end

    resources :users do
      get :delivery, on: :collection
      get :list, on: :collection
      get :find, on: :collection
      get :edit_data, on: :member
      put :update_data, on: :member
      put :update_permissions, on: :member
      get :display_addresses, on: :member
      get :display_section, on: :member
      get :crop, on: :member
      put :update_crop, on: :member
      put :clear_avatar, on: :member
      get :working_shifts, on: :collection
      get :t_shirts, on: :collection
      get :get_for_department, on: :collection
      put :update_for_department, on: :collection
      get :fire_reasons, on: :collection
      get :fired_people, on: :collection
    end

    resources :birthdays
    resources :fire_reasons
    resources :vacation_requests, only: [:index] do
      put :approve, on: :member
      put :decline, on: :member
    end
  end

  namespace :api do
    resources :departments, only: [:index, :show]
    resources :users, only: [:index] do
      get :rate, on: :collection
      get :rates, on: :collection
      get :feedbacks, on: :collection
      get :shifts, on: :collection
      get :nc_report, on: :collection
    end
    resources :leader_shifts, only: [:index]
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

Rails.application.routes.draw do

  resources :build_logs
  resources :annotations
  resources :submission_configs
  devise_for :users

  root 'start#index'

  get 'info',      to: 'start#info'
  get 'notfound',  to: 'start#notfound'


  match 'preferences' => 'preferences#edit', :as => :preferences, via: [:get, :patch]

  get 'bomb',        to: 'application#bomb'
  post 'report_csp', to: 'application#report_csp'

  # settings
  get   'settings',  to: 'start#settings'

  # profile
  get   'edit_profile',    to: 'start#edit_profile'
  patch 'update_profile',  to: 'start#update_profile'

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  resources :iconsets do
    resources :icons, only: [:edit, :destroy, :update]
  end

  resources :import_mappings, only: [:new, :create, :show] do
    post :apply_mapping, on: :member
    get :import_preview, on: :member
  end

  resources :maps do
    member do
      get :import
      post :import_preview
      post :importing
    end
    resources :tags, only: [:index, :show]
    resources :relations
    resources :people
    resources :layers do
      collection do
        post :search
        get :fetch_layers, to: 'layers#fetch_layers'
      end
      member do
        get :pack
        patch :build
        get :annotations
        get :relations
        get :images
        get :import
        post :import_preview
        post :importing
      end
      resources :places do
        resources :images
        resources :videos
        member do
          delete :delete_image_attachment
          post :sort
          get :clone
          get :edit_clone
          patch :update_clone
        end
      end
    end
  end

  namespace :admin do
    resources :users
    resources :groups
  end

  scope "/:locale" do
    scope "/:layer_id" do
      resources :submissions, :controller => "public/submissions", only: [:new, :create, :edit, :update, :index] do
        get :new_place, :controller => "public/submissions", :action => 'new_place'
        post :create_place, :controller => "public/submissions", :action => 'create_place'
        scope "/:place_id" do
          get :edit_place, :controller => "public/submissions", :action => 'edit_place'
          patch :update_place, :controller => "public/submissions", :action => 'update_place'
          get :new_image, :controller => "public/submissions", :action => 'new_image'
          post :create_image, :controller => "public/submissions", :action => 'create_image'
          get :finished, :controller => "public/submissions", :action => 'finished'
        end
      end
    end
  end

  namespace :public do
    resources :maps, only: [:show, :allplaces, :index], :defaults => { :format => :json } do
      resources :layers, only: [:show], :defaults => { :format => :json } do
        resources :places, only: [:show], :defaults => { :format => :json }
      end
      resources :tags, only: [:index], :defaults => { :format => :json }
      member do
        get :allplaces
      end

    end
  end
end
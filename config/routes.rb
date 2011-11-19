Fakebook::Application.routes.draw do
  resources :documents, :only => [ :index, :show, :update ] do
    get :search, :on => :collection
  end
  resources :tags, :only => :index do
    get :search, :on => :collection
  end
  root :to => 'documents#index'
end

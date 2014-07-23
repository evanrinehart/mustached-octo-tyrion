Rails.application.routes.draw do

  resources :activities, :only => [] do
    get :available_days
    get :available_times
    post :clear
    post :recurring
    
    resources :instances, :only => [:create, :destroy] do
      resources :bookings, :only => [:create, :destroy]
    end
  end


end

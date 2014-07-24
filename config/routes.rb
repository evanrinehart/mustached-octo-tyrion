Rails.application.routes.draw do

  resources :activities, :only => [] do
    get :available_days
    get :available_times
    post 'schedule/clear' => :clear
    post 'schedule/recurring' => :recurring
    
    resources :instances, :only => [:create, :destroy] do
      resources :bookings, :only => [:create, :destroy]
    end
  end


end

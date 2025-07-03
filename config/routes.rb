Rails.application.routes.draw do
  
  devise_for :users, skip: [:unlocks], path: '', path_names: {
    sign_in: 'sign_in',
    sign_out: 'sign_out'
  }, controllers: { sessions: 'users/sessions' }
  
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :sign_in
    delete 'sign_out', to: 'devise/sessions#destroy', as: :sign_out
  end
  
  get '/404', to: 'errors#not_fosaund'
  get '/500', to: 'errors#internasal_server_error'
  get '/400', to: 'errors#bad_reqsauest'

  # match '*unmatched', to: 'application#route_not_found', via: :all
  
  root "home#index"
  
  ###
  
  
  
  resources :home do
    collection do
      
    end
  end

  resources :users do
    collection do
      #dice_games
      post  :popup_balance
      get :popup_balance_modal
      
      #users
      get :user_image_modal
      post :update_user_image
    end
  end
  
  resources :messages do
    collection do
      get :load_messages
    end
  end
  
  resources :dice_games do
    collection do
      get :load_messages
      get :clear_game_history
      post :update_dice_game_settings
      get :dice_game_settings_modal
    end
  end

  mount ActionCable.server => '/cable'
end

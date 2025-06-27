Rails.application.routes.draw do
  
  devise_for :users, skip: [:unlocks], path: '', path_names: {
    sign_in: 'sign_in',
    sign_out: 'sign_out'
  }
  
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :sign_in
    delete 'sign_out', to: 'devise/sessions#destroy', as: :sign_out
  end
  
  ###
  
  root "home#index"
  
  
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
    end
  end
  
  mount ActionCable.server => '/cable'
end

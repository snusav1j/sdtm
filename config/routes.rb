Rails.application.routes.draw do
  devise_for :users, path: "", skip: [:unlocks], path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }
  devise_scope :user do
    # Аутентификация
    get    'signup',  to: 'devise/registrations#new',     as: :signup
    get    'login',   to: 'devise/sessions#new',           as: :login
    delete 'logout',  to: 'devise/sessions#destroy',       as: :logout
  
    # Редактирование профиля
    get    'settings', to: 'devise/registrations#edit',   as: :edit_user
  
    # Восстановление пароля
    get    'forgot',   to: 'devise/passwords#new',         as: :forgot_password
    post   'forgot',   to: 'devise/passwords#create'
    get    'reset',    to: 'devise/passwords#edit',        as: :edit_password
    put    'reset',    to: 'devise/passwords#update'
  
    # Подтверждение почты
    get    'confirm',  to: 'devise/confirmations#new',     as: :new_confirmation
    post   'confirm',  to: 'devise/confirmations#create'
    get    'confirm/verify', to: 'devise/confirmations#show', as: :confirm_verify
  
    # Разблокировка аккаунта
    get    'unlock',   to: 'devise/unlocks#new',           as: :new_unlock
    post   'unlock',   to: 'devise/unlocks#create'
    get    'unlock/verify', to: 'devise/unlocks#show',     as: :unlock_verify
  end

  root "home#index"


  resources :home do
    collection do

    end
  end  
end

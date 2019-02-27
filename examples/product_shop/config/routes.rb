Rails.application.routes.draw do
  root to: 'products#index'
  resources :products do
    member { get :history }
  end
end

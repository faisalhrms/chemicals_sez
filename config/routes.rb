Rails.application.routes.draw do
  root "home#index"

  resource :session, only: %i[new create destroy]
  get "forgot-password", to: "passwords#new", as: :new_password
  post "forgot-password", to: "passwords#create", as: :passwords
  get "reset-password", to: "passwords#edit", as: :edit_password
  patch "reset-password", to: "passwords#update", as: :password

  namespace :account do
    resource :profile, only: %i[show update]
    resource :appearance, only: %i[edit update]
    resource :password, only: %i[edit update]
  end

  namespace :developer do
    root "dashboard#index"
    resource :project, only: %i[show update]

    resources :nocs, only: %i[create update] do
      member { get :download }
    end

    resources :committee_meetings, only: %i[create update] do
      member { get :download }
    end

    resources :development_reports, only: %i[index show new create edit update] do
      member do
        post :submit_for_review
        get :download_attachment
      end
    end

    resources :reviews, only: %i[index show] do
      member do
        post :approve
        post :revert
      end
    end

    resources :submission_records, only: %i[index show]
  end

  namespace :authority do
    root "dashboard#index"
    resource :project, only: :show
    resources :development_reports, only: %i[index show] do
      member do
        get :export
        get :download_attachment
      end
    end
    resources :nocs, only: [] do
      member { get :download }
    end
    resources :committee_meetings, only: [] do
      member { get :download }
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

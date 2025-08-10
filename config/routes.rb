# frozen_string_literal: true

Rails.application.routes.draw do
  get  "sign_in", to: "sessions#new", as: :sign_in
  get  "switch", to: "sessions#switch", as: :switch_account

  # Clerk webhook endpoint
  post "webhooks/clerk", to: "webhooks#clerk"

  get :dashboard, to: "dashboard#index"

  namespace :settings do
    inertia :appearance
  end

  # Sentry testing routes (only available in non-production)
  unless Rails.env.production?
    get "sentry_test/backend_error", to: "sentry_test#test_backend_error"
    get "sentry_test/frontend_error", to: "sentry_test#test_frontend_error"
    get "sentry_test/performance", to: "sentry_test#test_performance"
  end

  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end

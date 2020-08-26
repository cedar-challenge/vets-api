# frozen_string_literal: true

HealthQuest::Engine.routes.draw do
  namespace :v0, defaults: { format: :json } do
    resources :appointments, only: %i[index] do
    end
  end

  namespace :v1, defaults: { format: :json } do
    get '/Appointment/', to: 'appointments#index'
  end
end
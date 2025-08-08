Rails.application.routes.draw do
  get "weather/show"

  get "up" => "rails/health#show", as: :rails_health_check

  root "weather#show"
end

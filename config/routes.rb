Rails.application.routes.draw do
  post '/health_inspections' => 'health_inspections#show_to_extension'
  post '/recently_ordered' => 'health_inspections#show_to_recently_ordered'
  get '/health_inspections/:vendor_id' => 'health_inspections#show_to_webview'
  get '/health_inspections' => 'health_inspections#index'
  get '/index_eats' => 'health_inspections#index_eats'
  root 'health_inspections#index'
end

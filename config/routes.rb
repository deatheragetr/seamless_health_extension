Rails.application.routes.draw do
  root 'health_inspections#index'

  post '/health_inspections' => 'health_inspections#show_to_extension'
  post '/recently_ordered' => 'health_inspections#show_to_recently_ordered'
  post '/seamless_show' => 'health_inspections#seamless_show'

  get '/health_inspections' => 'health_inspections#index'
  get '/health_inspections/:vendor_id' => 'health_inspections#show_to_webview'
  get '/index_eats' => 'health_inspections#index_eats'
end

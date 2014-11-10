Rails.application.routes.draw do
  get '/health_inspections' => 'health_inspections#show_to_extension'
  get '/health_inspections/:vendor_id' => 'health_inspections#show_to_webview'
end

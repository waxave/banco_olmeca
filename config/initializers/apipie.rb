Apipie.configure do |config|
  config.app_name     = 'Banco Olmeca'
  config.api_base_url = '/api'
  config.doc_base_url = '/api-docs'
  config.app_info     = 'Documentation of Banco Olmeca API'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end

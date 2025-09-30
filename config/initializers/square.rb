# config/initializers/square.rb

Rails.application.config.after_initialize do
  if Rails.application.credentials.square.present?
    Square.configure do |config|
      config.access_token = Rails.application.credentials.square[:access_token]
      config.environment = Rails.env.production? ? 'production' : 'sandbox'
    end
  else
    Rails.logger.warn("Square credentials are not configured! Please run: bin/rails credentials:edit")
  end
end
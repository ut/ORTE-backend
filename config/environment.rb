# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
      enable_starttls_auto: true,
      address: Rails.application.credentials.dig(:mail, :address),
      domain: Rails.application.credentials.dig(:mail, :domain),
      port: '465',
      ssl: true,
      authentication: :login,
      user_name: Rails.application.credentials.dig(:mail, :user_name),
      password:  Rails.application.credentials.dig(:mail, :password)
}




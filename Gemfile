source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '0.21.0'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# Use Passenger as the app server
# gem 'passenger', '~> 5.0'
# Use Redis adapter to run Action Cable in production
gem 'redis-rails'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.11'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Twilio
gem 'twilio-ruby', '~> 5.5.1'
# AWS SES
gem 'aws-ses', '~> 0.6.0', :require => 'aws/ses'
# Rack Attack
gem 'rack-attack'
# Slack Notifications
gem 'slack-notifier'
# Exception Notifications
gem 'exception_notification'
# attr_encrypted
gem 'attr_encrypted', '~> 3.0.3'
# mock/stub
gem 'webmock'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


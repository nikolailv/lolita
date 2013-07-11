source 'http://rubygems.org'

gemspec

group :test, :development do
  unless ENV['CI']
    gem 'byebug'
  end
  gem 'fabrication', '~> 1.3.2'
  gem 'rspec', '~> 2.13'
  gem 'capybara', '~> 2'
  gem 'ffaker', '~> 1'
  gem 'generator_spec', '~> 0.9.0'
end

gem 'simplecov', :require => false, :group => :test

group :rails do
  gem 'rails' , '~> 4.0.0'
  gem 'rspec-rails', '~> 2.13'
  gem 'coffee-rails', '>=0'
  gem 'therubyracer', '~> 0.11.4'
end

group :mongoid do
	gem 'bson_ext', '~> 1.9.0'
  gem 'mongo', '~> 1.9.0'
	gem 'mongoid', '>=0'
end

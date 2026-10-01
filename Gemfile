source "https://rubygems.org"

ruby "~> 4.0.0"

gem "rails", "8.1.4"
gem "pg", "1.6.3"
gem "puma", "8.0.2"
gem "propshaft", "1.3.2"
gem "bcrypt", "3.1.22"
gem "bootsnap", "1.26.0", require: false

gem "importmap-rails", "2.2.3"
gem "turbo-rails", "2.0.23"
gem "stimulus-rails", "1.3.4"
gem "tailwindcss-rails", "4.6.0"

gem "pundit", "2.5.2"
gem "caxlsx", "4.5.0"
gem "caxlsx_rails", "0.7.2"

group :development, :test do
  gem "debug", "1.11.1", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", "8.0.6", require: false
  gem "bundler-audit", "0.9.3", require: false
  gem "rubocop-rails-omakase", "1.1.0", require: false
end

group :development do
  gem "web-console", "4.3.0"
end

group :deployment do
  gem "capistrano", "3.20.1", require: false
  gem "capistrano-rails", "1.7.0", require: false
  gem "capistrano-bundler", "2.2.0", require: false
  gem "capistrano3-puma", "8.1.0", require: false
end

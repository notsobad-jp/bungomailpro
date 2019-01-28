source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.0'

gem 'rails', '~> 5.2.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'haml-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'sorcery'
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'pundit'
gem 'rack', '>= 2.0.6'
gem 'loofah', '>= 2.2.3'
gem 'algoliasearch'
gem 'activerecord-import'
gem 'composite_primary_keys', '~> 11.0'
gem 'kaminari'
gem 'rails-i18n', '~> 5.1'

group :production do
  gem 'scout_apm'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'erb2haml'
  gem 'annotate'
  gem 'letter_opener'
  gem 'rack-mini-profiler', require: false
end

#
#              .+????.                 
#            .?????????:.              
#         .,??????????????.            
#       .???????????????????..         
#    ..?????????.. ..??????????.       
#  .?????????~.       ..?????????..    
# I????????..            .+????????.   
#  .????~. .,,,,.    ,,,,,...????+.    
#   .?..   .????:    ?????.   .=.      
#          .????:    ?????.            
#          .????:    ?????.            
#    =??????????????????????????:      
#    =??????????????????????????,      
#    =??????????????????????????,      
#    .......????:....+????.......      
#          .????:    ?????.            
#          .????:    ?????.            
#    ~?+++++?????++++??????++++?,      
#    =??????????????????????????,      
#    =??????????????????????????,      
#    .......????~....+????.......      
#          .????:    ?????.            
#          .????:    ?????.            
#           ????:    ?????.            
#          ......    ......
#
# =======================================================================
# Base DeveloperTown Rails Application Template
# =======================================================================
#
# The following template builds out a basic rails application with the
# following high-level capabilities:
#
# * Authentication/Authorization with Devise/Authority
# * HAML + Twitter Bootstrap (Sass version)
# * SimpleForm
# * Deployment with capistrano + foreman + puma
# * Testing via rspec+factory_girl+guard, coverage with simplecov

run "echo \"source 'https://rubygems.org'\" > Gemfile"

# Core app dependencies
gem "rails", '~> 4.0'
gem 'pg' # Postgres
gem 'haml'
gem 'haml-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'kaminari-bootstrap' # Pagination
gem 'simple_form'
gem 'devise'
gem 'authority'
gem 'request_store'

# In browser profiling
gem "rack-mini-profiler"

# Twitter bootstrap support
gem "bootstrap-sass"
gem "underscore-rails"
gem "font-awesome-sass-rails"

# JS libraries
gem 'rails-timeago'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'

# Browser independent CSS support
gem 'bourbon'

# Broswser detection, feature handling
gem 'modernizr-rails'
gem 'browser'

# Attachment handling
gem 'paperclip' 
gem 'aws-sdk'
gem 'aws-ses', :require => 'aws/ses'

# Asset precompilation
gem 'libv8'
gem 'therubyracer', :require => false
gem 'uglifier'
gem 'yui-compressor'

# Deployment/runtime
gem 'foreman', :require => false
gem 'unicorn'
gem "figaro"

gem_group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
  gem 'quiet_assets'
end

gem_group :development, :test do
  gem 'yard', :require => false
  gem 'guard', :require => false
  gem 'guard-rspec', :require => false
  gem 'terminal-notifier-guard'
  #gem 'growl', :require => false
  gem "pry"
  gem "pry-nav"
  gem "pry-remote"
end

# Testing
gem_group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda'
  gem "timecop"
  gem "faker"
  gem "codeclimate-test-reporter"
end

#get "https://raw.github.com/developertown/rails3-application-templates/master/files/.ruby-version", ".ruby-version"
run "rbenv rehash"

run("bundle install")

# Set app configuration
app_config = <<-CFG
    config.generators do |g|
      g.test_framework :rspec, :views => false
      g.template_engine :haml
    end
CFG
environment app_config
environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'

environment 'config.assets.css_compressor = :yui', env: 'production'

run "rm config/database.yml"  # We're about to overwrite it...

db_name = ask("Database Name?")
file "config/database.yml", <<-DB
  <%
    user = ENV['USER'] || ""
    host = ENV["BOXEN_POSTGRESQL_HOST"] || "localhost"
    port = ENV["BOXEN_POSTGRESQL_PORT"] || 5432
  %>

  development: &development
    adapter: postgresql
    encoding: utf8
    pool: 5
    timeout: 5000
    database: #{db_name}_dev
    port: <%= port %>
    host: <%=host%>
    username: <%=user%>
    password:
    
  test: &test
    <<: *development
    database: #{db_name}_test
DB

generate 'figaro:install'
generate 'simple_form:install --bootstrap'
generate 'devise:install'
generate 'devise:views', '-e', 'erb'
generate :model, 'user'
generate 'devise', 'user'
generate :controller, 'home', 'index'
generate 'rspec:install'

run "rm .rspec"  # We're about to overwrite it...
get "https://raw.github.com/developertown/rails3-application-templates/master/files/.rspec", ".rspec"

run "bundle exec guard init"
run "rm spec/spec_helper.rb"  # We're about to overwrite it...
get "https://raw.github.com/developertown/rails3-application-templates/master/files/spec/spec_helper.rb", "spec/spec_helper.rb"
run "rm Guardfile"  # We're about to overwrite it...
get "https://raw.github.com/developertown/rails3-application-templates/master/files/Guardfile", "Guardfile"
run "rm -rf test" # This is the unneeded test:unit test dir

# Foreman configuration
get "https://raw.github.com/developertown/rails3-application-templates/master/files/Procfile", "Procfile"

run "bundle exec guard init"
run "rm spec/spec_helper.rb"  # We're about to overwrite it...
get "https://raw.github.com/developertown/rails3-application-templates/master/files/spec/spec_helper.rb", "spec/spec_helper.rb"
run "rm Guardfile"  # We're about to overwrite it...
get "https://raw.github.com/developertown/rails3-application-templates/master/files/Guardfile", "Guardfile"
run "rm -rf test" # This is the unneeded test:unit test dir

run "rm app/views/devise/confirmations/*" # We are going to replace this with our default templates
run "rm app/views/devise/mailer/*" 
run "rm app/views/devise/passwords/*" 
run "rm app/views/devise/registrations/*" 
run "rm app/views/devise/sessions/*" 
run "rm app/views/devise/shared/*" 
run "rm app/views/devise/unlocks/*" 

devise_views = [
                'app/views/devise/confirmations/new.html.haml',
                'app/views/devise/mailer/confirmation_instructions.html.haml',
                'app/views/devise/mailer/reset_password_instructions.html.haml',
                'app/views/devise/mailer/unlock_instructions.html.haml',
                'app/views/devise/passwords/edit.html.haml',
                'app/views/devise/passwords/new.html.haml',
                'app/views/devise/registrations/edit.html.haml',
                'app/views/devise/registrations/new.html.haml',
                'app/views/devise/sessions/new.html.haml',
                'app/views/devise/shared/_links.haml',
                'app/views/devise/unlocks/new.html.haml'
               ]
                
devise_views.each do |view|
  get "https://raw.github.com/developertown/rails3-application-templates/master/files/#{view}", view
end

insert_into_file 'app/assets/javascripts/application.js', "//= require bootstrap\n//= require turbolinks\n//=require jquery.turbolinks", :after => "jquery_ujs\n"

template_stylesheets = [
                        'app/assets/stylesheets/application.css.scss',
                        'app/assets/stylesheets/bootstrap-generators.scss',
                        'app/assets/stylesheets/generators/alerts.css.scss',
                        'app/assets/stylesheets/generators/baseline-sitewide.css.scss',
                        'app/assets/stylesheets/generators/breadcrumb.css.scss',
                        'app/assets/stylesheets/generators/buttons.css.scss',
                        'app/assets/stylesheets/generators/navbar.css.scss',
                        'app/assets/stylesheets/generators/navs.css.scss',
                        'app/assets/stylesheets/generators/tables.css.scss',
                        'app/assets/stylesheets/sitewide/application-sitewide.css.scss',
                        'app/assets/stylesheets/sitewide/footer.css.scss',
                        'app/assets/stylesheets/supportive/PIE.htc',
                        'app/assets/stylesheets/supportive/PIE_IE678.js',
                        'app/assets/stylesheets/supportive/bootstrap-ie7.css',
                        'app/assets/stylesheets/supportive/boxsizing.htc',
                        'app/assets/stylesheets/supportive/font-awesome-ie7_3.2.1.css'
                        ]

empty_directory "app/assets/stylesheets/generators"
empty_directory "app/assets/stylesheets/sitewide"
empty_directory "app/assets/stylesheets/supportive"
empty_directory "app/assets/stylesheets/views"

template_stylesheets.each do |view|
  get "https://raw.github.com/developertown/rails3-application-templates/master/files/#{view}", view
end

empty_directory "app/assets/javascripts/views"

get "https://raw.github.com/developertown/rails3-application-templates/master/files/app/assets/javascripts/application.js.coffee", "app/assets/javascripts/applicaiton.js.coffee"

run "rm app/views/layouts/application.html.erb"
# get "https://raw.github.com/developertown/rails3-application-templates/master/files/app/views/layouts/application.html.haml", "app/views/layouts/application.html.haml"

route "root :to => 'home#index'"
insert_into_file 'config/routes.rb', "match ':action' => 'home#:action'", :after => "# match ':controller(/:action(/:id))(.:format)'\n"

# Deploy magic...
empty_directory "deploy"
file "deploy/after_restart.rb", ""
file "deploy/before_restart.rb", ""
get "https://raw.github.com/developertown/rails3-application-templates/master/files/deploy/before_migrate.rb", "deploy/before_migrate.rb"

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

run "bundle exec rake db:create db:migrate"
run "RAILS_ENV=test bundle exec rake db:create db:migrate"

puts ""
puts ""
puts ""
puts "All Set!"
puts ""
puts "Some setup you must do manually:"
puts ""
puts "   1. Install Zeus (or change Guardfile to not use Zeus)"
puts "   2. Update app/views/layouts/application.html.haml with the new project name"
puts "   3. Before deploying to CI, create a CI database and environment configuration."
puts "   4. Before deploying to CI, update config/deploy.rb and the associated "
puts "      configs with appropriate configuration."
puts ""
puts ""

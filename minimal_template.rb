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
# Minimal DeveloperTown Rails Application Template
# =======================================================================
#
# The following template builds out a basic rails application with the
# following high-level capabilities:
#
# * HAML + Twitter Bootstrap (Sass version)
# * SimpleForm
# * Testing via rspec+factory_girl+guard, coverage with simplecov

URL_BASE = "https://raw.github.com/developertown/rails-templates/"

def template_branch
  ENV['TEMPLATE_BRANCH'] || "master"
end

def remote_file(path_fragment)
  get URL_BASE + template_branch + "/files/" + path_fragment, path_fragment
end

run "echo \"source 'https://rubygems.org'\" > Gemfile"

# Core app dependencies
gem "rails", '~> 4.2'
gem 'pg' # Postgres
gem 'haml'
gem 'haml-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'kaminari-bootstrap' # Pagination
gem 'simple_form'
gem 'request_store'

# In browser profiling
gem "rack-mini-profiler"

# Twitter bootstrap support
gem 'bootstrap-sass'
gem 'bootstrap-sass-extras'
gem "underscore-rails"
gem "font-awesome-rails"

# JS libraries
gem 'rails-timeago'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'nprogress-rails'

# Browser independent CSS support
gem 'bourbon'

# Broswser detection, feature handling
gem 'modernizr-rails'
gem 'browser'

# Attachment handling
gem 'carrierwave'
gem 'mini_magick'
gem 'fog'
gem 'fastimage', require: false

# Asset precompilation
gem 'uglifier'
gem 'yui-compressor'

# Deployment/runtime
gem 'foreman', :require => false
gem 'unicorn'

# Standardized Health Checks (for ELB/Pingdom/etc)
gem 'health_check'
gem 'rollbar'

gem_group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
  gem 'quiet_assets'
  gem "spring"
  gem "spring-commands-rspec"
  gem "annotate"
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
  gem "pry-rails"
  gem 'did_you_mean'
end

# Testing
gem_group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda'
  gem "shoulda-callback-matchers"
  gem "timecop"
  gem "faker"
  gem "codeclimate-test-reporter"
end

run "rbenv rehash"

run("bundle install")

# Set app configuration

# The CI environment is very production-like:
copy_file 'config/environments/production.rb', 'config/environments/ci.rb'

app_config = <<-CFG
config.generators do |g|
      g.test_framework :rspec, :views => false
      g.template_engine :haml
    end
CFG
environment app_config
environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'

environment 'config.assets.css_compressor = :yui', env: ['ci', 'production']
environment 'config.active_record.dump_schema_after_migration = false', env: ['ci', 'production']

ci_secret_key_base = <<-CFG

ci:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

CFG
append_to_file 'config/secrets.yml', ci_secret_key_base


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

run "bundle exec rake db:create db:migrate"

generate 'simple_form:install --bootstrap'
generate :controller, 'home', 'index'
generate 'rspec:install'

run "rm .rspec"  # We're about to overwrite it...
remote_file ".rspec"

remote_file "lib/tasks/auto_annotate_models.rake"

run "bundle exec guard init"
run "rm spec/spec_helper.rb"  # We're about to overwrite it...
remote_file "spec/spec_helper.rb"
run "rm Guardfile"  # We're about to overwrite it...
remote_file "Guardfile"
run "rm -rf test" # This is the unneeded test:unit test dir

# Foreman configuration
remote_file "Procfile"

# Health check initializer
remote_file "config/initializers/health_check.rb"

run "bundle exec guard init"
run "rm spec/spec_helper.rb"  # We're about to overwrite it...
remote_file "spec/spec_helper.rb"
run "rm Guardfile"  # We're about to overwrite it...
remote_file "Guardfile"
run "rm -rf test" # This is the unneeded test:unit test dir

run "rm app/assets/stylesheets/*"
template_stylesheets = [
                        'app/assets/stylesheets/application.scss',
                        'app/assets/stylesheets/bootstrap-generators.scss',
                        'app/assets/stylesheets/generators/alerts.scss',
                        'app/assets/stylesheets/generators/baseline-sitewide.scss',
                        'app/assets/stylesheets/generators/breadcrumb.scss',
                        'app/assets/stylesheets/generators/buttons.scss',
                        'app/assets/stylesheets/generators/navbar.scss',
                        'app/assets/stylesheets/generators/navs.scss',
                        'app/assets/stylesheets/generators/tables.scss',
                        'app/assets/stylesheets/sitewide/application-sitewide.scss',
                        'app/assets/stylesheets/sitewide/footer.scss',
                        'app/assets/stylesheets/supportive/PIE.htc',
                        'app/assets/stylesheets/supportive/PIE_IE678.js',
                        'app/assets/stylesheets/supportive/bootstrap-ie7.scss',
                        'app/assets/stylesheets/supportive/boxsizing.htc',
                        'app/assets/stylesheets/supportive/font-awesome-ie7_3.2.1.scss'
                        ]

empty_directory "app/assets/stylesheets/generators"
empty_directory "app/assets/stylesheets/sitewide"
empty_directory "app/assets/stylesheets/supportive"
empty_directory "app/assets/stylesheets/views"
run "echo  > app/assets/stylesheets/views/.gitkeep"

template_stylesheets.each do |view|
  remote_file view
end

empty_directory "app/assets/javascripts/views"
run "echo  > app/assets/javascripts/views/.gitkeep"

run "rm -rf app/assets/javascripts/*"

remote_file "app/assets/javascripts/application.js.coffee"

run "rm app/views/layouts/application*"
remote_file "app/views/layouts/application.html.haml"

remote_file "app/controllers/browser_controller.rb"
empty_directory 'app/views/browser'
remote_file "app/views/browser/upgrade.html.haml"

route "root :to => 'home#index'"
route "get :upgrade, controller: :browser"

insert_into_file 'config/routes.rb', "match ':action' => 'home#:action'", :after => "# match ':controller(/:action(/:id))(.:format)'\n"

run "touch config/initializers/assets.rb"
append_to_file 'config/initializers/assets.rb', "Rails.application.config.assets.precompile += %w( supportive/bootstrap-ie7.css )\n"
append_to_file 'config/initializers/assets.rb', "Rails.application.config.assets.precompile += %w( supportive/font-awesome-ie7_3.2.1.css )\n"

#build magic
empty_directory "build"
remote_file "build/setup.sh"
remote_file "build/test.sh"

run "bundle exec rake db:migrate"

run "spring binstub --all"

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

puts ""
puts ""
puts ""
puts "All Set!"
puts ""
puts "Some setup you must do manually:"
puts ""
puts "   1. Update app/views/layouts/application.html.haml with the new project name"
puts "   2. Before deploying to CI, create a CI database and environment configuration."
puts "   3. Create the rollbar project"
puts "   4. Create Code Climate project and add token to builds/setup.sh"
puts ""

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Requiring custom test helpers
Dir[File.dirname(__FILE__) + "/test_helpers/*.rb"].sort.each { |f| require File.expand_path(f) }

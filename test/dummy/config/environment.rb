require "rails"
require "active_job/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)
require "active_storage"

class DummyApp < Rails::Application
	config.secret_key_base = "test"
  config.active_storage.service = :local
end

# Initialize the DummyApp application.
DummyApp.initialize!

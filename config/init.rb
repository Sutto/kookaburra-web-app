require 'config/dependencies.rb'
 
use_test            :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex]           = false
  c[:session_store]       = 'cookie'
  c[:session_secret_key]  = '9c76db7172ec610707fea990f2402f8872d51a84'  # required for cookie session store
  c[:session_id_key]      = '__kookaburra_session__'
end
 
Merb::BootLoader.before_app_loads do
  # Merb::Plugins.config[:exceptions] = {
  #   :web_hooks       => [],
  #   :email_addresses => ['sutto@sutto.net'],
  #   :app_name        => "Kookaburra",
  #   :email_from      => "sutto@sutto.net",
  #   :environments    => ['production']
  # }
end
 
Merb::BootLoader.after_app_loads do
  # Initialize the connection to the DRB server.
  Message.init!
end

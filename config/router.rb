Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  match('/update-nick').to(:controller => "user", :action => "update_nick").name(:update_nick)
  match('/statuses/:action(.:format)').to(:controller => "statuses").name(:statuses)
  match('/:username', :username => /^[A-Za-z\-\_0-9]+$/).to(:controller => "statuses", :action => "user").name(:user)
  match('/:username/with_friends', :username => /^[A-Za-z\-\_0-9]+$/).to(:controller => "statuses", :action => "with_friends")
  match('/direct_messages.xml').to(:controller => "statuses", :action => "dm", :format => "xml")
  match('/').to(:controller => 'statuses', :action =>'index').name(:home)
end
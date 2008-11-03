class Application < Merb::Controller
  
  before :authenticate
  
  private
  
  def authenticate
    Merb.logger.debug "Current username: #{session[:user].inspect}"
    if session[:user].to_s !~ /^([A-Za-z][A-Za-z\-\_0-9]+[A-Za-z])$/
      user = basic_authentication("Kookaburra").authenticate do |username, password|
        username unless username.blank? || username !~ /^([A-Za-z][A-Za-z\-\_0-9]+[A-Za-z])$/
      end
      if user =~ /^([A-Za-z][A-Za-z\-\_0-9]+[A-Za-z])$/
        session[:user] = user
      else
        if false &&  params[:format].to_s == "html"
          # Redirect to a username page
        else
          basic_authentication.request
        end
      end
    end
  end
  
end
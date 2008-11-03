class User < Application

  def update_nick
    updated = false
    if params[:nick] && params[:nick].to_s.strip =~ /^([A-Za-z][A-Za-z\-\_0-9]+[A-Za-z])$/
      session[:user] = $1
      Merb.logger.debug "Set new nick to #{$1}"
      updated = true
    end
    # Finally, respond accordingly
    redirect url(:home)
  end
  
end

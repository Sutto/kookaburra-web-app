class User < Application

  def update_nick
    # If we've got a valid nick, update the stored nick.
    if params[:nick] && params[:nick].to_s.strip =~ /^([A-Za-z][A-Za-z\-\_0-9]+[A-Za-z])$/
      session[:user] = $1
      Merb.logger.debug "Set users new nick to #{$1}"
    end
    # Finally, respond accordingly
    redirect url(:home)
  end
  
end

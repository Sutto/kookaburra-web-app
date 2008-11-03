class Exceptions < Merb::Controller
  
  # handle NotFound exceptions (404)
  def not_found
    @page_title = "Page Not Found"
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    @page_title = "That's not acceptible"
    render :format => :html
  end
  
  def irc_server_error
    @page_title = "Someone setup us the bomb."
  end

end
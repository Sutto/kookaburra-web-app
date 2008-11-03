class Statuses < Application

  layout "application"

  provides :xml, :html

  def index
    @page_title = "Public Timeline - Kookaburra"
    @messages = Message.all
    display @messages, 'statuses/index'
  end    
  
  def replies
    @page_title = "Public replies to your - Kookaburra"
    render :layout => (params[:format].blank? || params[:format].to_s == "html"), :format => (params[:format] || "text/html")
  end
  
  # Basically, render the friends timeline instead.
  def friends_timeline
    index
  end
  
  def update
    @message = Message.create(:contents => params[:status], :from => session[:user])
    if params[:format].blank? || params[:format].to_s == "html"
      redirect url(:home)
    else
      render :layout => false
    end
  end
  
  def messages_since
    since_id = params[:since_id].to_i
    @messages = Message.all.select { |m| m.id > since_id }
    render :layout => false
  end

  
end

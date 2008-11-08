class Statuses < Application

  layout "application"

  provides :xml, :html

  def index
    @page_title = "Public Timeline - kookaburra"
    @messages = Message.all
    display @messages, 'statuses/index'
  end
  
  def replies
    @messages = Message.replies_to(session[:user])
    @page_title = "Replies to you"
    display @messages
  end
  
  # Basically, render the friends timeline instead.
  def friends_timeline
    index
  end
  
  def update(status)
    @message = Message.create(:contents => status, :from => session[:user])
    if params[:format].blank? || params[:format].to_s == "html"
      redirect url(:home)
    else
      render :layout => false
    end
  end
  
  def messages_since(since_id)
    since_id = since_id.to_i
    @messages = Message.all.select { |m| m.id > since_id }
    render :layout => false
  end
  
  def user(username)
    @messages = Message.from(username)
    @page_title = "All messages from #{h username} - kookaburra"
    render
  end
  
  def with_friends
    redirect url(:home)
  end
  
  def dm
    @messages = []
    display @messages
  end

  
end

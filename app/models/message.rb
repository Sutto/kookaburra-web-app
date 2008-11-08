require 'drb'

class IrcServerError < StandardError; end

class Message
  
  NAME_PART    = /([A-Za-z\-\_0-9]+)/
  CHANNEL_NAME = /([#\$&]+#{NAME_PART})/
  
  attr_accessor  :id, :from, :target, :contents, :created_at
  cattr_accessor :drb_obj
  
  # Creates a new message from a given set of information, usually
  # retrieved from a database.
  def initialize(id, from, target, contents, created_at = Time.now, mutate = true)
    self.id         = id
    self.from       = from
    self.target     = target
    self.contents   = contents
    self.created_at = created_at
    # Convert the format of the message.
    mutate_message! if mutate
  end
  
  @@drb_obj = nil
  
  # Connect to the move drb server so that
  # we can access remove errors etc.
  def self.init!
    DRb.start_service()
    @@drb_obj = DRbObject.new(nil, 'druby://localhost:9000')
  end
  
  def self.all(limit = 100)
    convert! @@drb_obj.all_messages(limit)
  rescue DRb::DRbConnError
    raise IrcServerError.new
  end
  
  def self.from(username)
    convert! @@drb_obj.messages_from(username)
  rescue DRb::DRbConnError
    raise IrcServerError.new
  end
  
  def self.replies_to(username)
    convert! @@drb_obj.replies_to(username)
  rescue DRb::DRbConnError
    raise IrcServerError.new
  end
  
  def self.create(args = {})
    [:from, :contents].each { |m| return false if args[m].blank? }
    # Check the format - if the hashtag is at the end
    # and there is some punctuation before it, we can
    # safely trim the hashtag.
    if args[:target].blank? && args[:contents] =~ /(.*[\.\!\?])\s+#{CHANNEL_NAME}\s*$/
      args[:target]   = $2
      args[:contents] = $1
    # Otherwise, it might form a part of the sentence
    # So trimming it would prove detrimental.
    elsif args[:target].blank? && args[:contents] =~ CHANNEL_NAME
      args[:target] = $1
    # Otherwise, we'll send it to #general
    else
      args[:target] ||= "#general"
    end
    # Filter / mutate the outgoing text ot have the correct format.
    args[:contents] = twitter2irc(args[:contents])
    # Finally, attempt to create it.
    resp = @@drb_obj.remote_message(args[:from], args[:target], args[:contents])[0..4]
    # and return a new message object.
    return self.new(*resp)
  rescue
    raise IrcServerError.new
  end
  
  def ==(other)
    self.id == other.id
  end
  
  private
  
  def mutate_message!    
    self.contents = self.class.irc2twitter(self.contents)
  end
  
  def self.convert!(items)
    items.map { |m| self.new(*m[0..4]) }.sort { |a,b| b.created_at <=> a.created_at }
  end
  
  def self.irc2twitter(contents)
    contents  = "@#{$1} #{$2}" if contents =~ /^(\S+): (.*)$/i
    return contents
  end
  
  def self.twitter2irc(contents)
    contents =  "#{$1}: #{$2}" if contents =~ /^@(\S+) (.*)$/i
    return contents
  end
  
end
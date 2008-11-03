require 'drb'

class IrcServerError < StandardError; end

class Message
  
  NAME_PART    = /([A-Za-z\-\_0-9]+)/
  CHANNEL_NAME = /([#\$&]+#{NAME_PART})/
  
  attr_accessor :id, :from, :target, :contents, :created_at, :reply
  
  def initialize(id, from, target, contents, created_at)
    self.id         = id
    self.from       = from
    self.target     = target
    self.contents   = contents
    self.created_at = created_at
    mutate_message!
  end
  
  @@drb_obj = nil
  
  def self.drb_obj; @@drb_obj; end
  
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
  
  private
  
  def mutate_message!    
    self.contents  = "@#{$1} #{$2}" if self.contents =~ /^(\S+): (.*)$/i
  end
  
  def self.create(args = {})
    Merb.logger.debug "Message arguments: #{args.inspect}"
    [:from, :contents].each { |m| return false if args[m].blank? }
    if args[:target].blank? && args[:contents] =~ /(.*[\?\!\.])\s+#{CHANNEL_NAME}\s*$/
      args[:target]   = $2
      args[:contents] = $1
    elsif args[:target].blank? && args[:contents] =~ CHANNEL_NAME
      args[:target] = $1
    else
      args[:contents] ||= "#general"
    end
    args[:target] ||= "#general"
    args[:contents] = twitter2irc(args[:contents])
    resp = @@drb_obj.remote_message(args[:from], args[:target], args[:contents])[0..4]
    return self.new(*resp)
  rescue
    raise IrcServerError.new
  end
  
  private
  
  def self.convert!(items)
    items.map { |m| self.new(*m[0..4]) }.sort { |a,b| b.created_at <=> a.created_at }
  end
  
  def self.irc2twitter(contents)
    contents
  end
  
  def self.twitter2irc(contents)
    contents =  "#{$1}: #{$2}" if contents =~ /^@(\S+) (.*)$/i
    return contents
  end
  
end
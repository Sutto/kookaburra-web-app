require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Message, "when working with a raw model" do
  
  it "should require 4 arguments for it's constructor" do
    # No arguments
    proc do
      Message.new
    end.should raise_error(ArgumentError)
    # One argument
    proc do
      Message.new(1)
    end.should raise_error(ArgumentError)
    # Two arguments
    proc do
      Message.new(1, "SuttoL")
    end.should raise_error(ArgumentError)
    # Three arguments
    proc do
      Message.new(1, "SuttoL", "#general")
    end.should raise_error(ArgumentError)
    # Four arguments - ok
    proc do
      Message.new(1, "SuttoL", "#general", "Hola from the app")
    end.should_not raise_error(ArgumentError)
  end
  
  it "should take an optional created_at argument on the constructor" do
    proc do
      Message.new(1, "SuttoL", "#general", "Hola from the app", Time.now)
    end.should_not raise_error(ArgumentError)
  end
  
  it "should automatically mutate the message contents by default" do
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!")
    m.contents.should_not == "Darcy: Hi there!"
    m.contents.should == "@Darcy Hi there!"
  end
  
  it "shouldn't mutate the message if told not to" do
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!", Time.now, false)
    m.contents.should_not == "@Darcy Hi there!"
    m.contents.should == "Darcy: Hi there!"
  end
  
  it "should have an id field" do
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!", Time.now, false)
    m.id.should == 1
  end
  
  it "should have a from field" do
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!", Time.now, false)
    m.from.should == "SuttoL"
  end
  
  it "should have a target field" do
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!", Time.now, false)
    m.target.should == "#ninjabots"
  end
  
  it "should have a contents field" do
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!", Time.now, false)
    m.contents.should == "Darcy: Hi there!"
  end
  
  it "should have a created_at field" do
    t = Time.now - 60
    m = Message.new(1, "SuttoL", "#ninjabots", "Darcy: Hi there!", t, false)
    m.created_at.should == t
  end
  
end

class MockIRCServer
  
  # Order: id, from, target, contents, created_at
  
  attr_accessor :messages, :max_id
  
  def initialize
    @messages = []
    @max_id   = 0
  end
  
  def remote_message(from, target, contents)
    self.messages << [@max_id += 1, from, target, contents, Time.now]
    return self.messages.last
  end
  alias add remote_message
  
  def messages_from(user)
    self.messages.select { |m| m[1].downcase == user.downcase }
  end
  
  def all_messages(limit)
    self.messages[0..(limit - 1)]
  end
  
  def replies_to(user)
    self.messages.select { |m| m[3] =~ /^#{user}:? /i }
  end
  
end

describe Message, "when dealing with the drb server" do
  before :each do
    Message.drb_obj = MockIRCServer.new
  end
  
  describe "Getting all messages" do
    
    it "should return no messages by default" do
      Message.all.should == []
    end
    
    it "should return up to the limit no. of messages" do
      6.times { Message.drb_obj.add("Darcy", "Something", "Another") }
      Message.all(5).length.should == 5
    end
    
    it "should be ordered by the created_at date - highest first" do
      6.times { Message.drb_obj.add("Darcy", "Something", "Another") }
      ms = Message.all
      ms.should == ms.sort_by { |m| m.created_at }.reverse
    end
    
    it "should have uniq id's for each message" do
      6.times { Message.drb_obj.add("Darcy", "Something", "Another") }
      ms  = Message.all
      ids = ms.map { |m| m.id }
      ids.should == ids.uniq
      ids.sort.should == [1, 2, 3, 4, 5, 6]
    end
    
    it "should not have the same values as the drb object res" do
      6.times { Message.drb_obj.add("Darcy", "Something", "Another") }
      ms = Message.drb_obj.all_messages(100)
      msgs = Message.all(100)
      ms.should_not == msgs
    end
    
    it "should convert all to messages" do
      6.times { Message.drb_obj.add("Darcy", "Something", "Another") }
      msgs = Message.all
      msgs.inject(true) { |acc, current| acc && current.is_a?(Message) }.should == true
    end
    
  end
  
  describe "Getting all messages from a specific user" do
    
    before :each do
      6.times { Message.drb_obj.add("Darcy", "Something", "Another") }
      7.times { Message.drb_obj.add("Bob", "Something", "Another")   }
      2.times { Message.drb_obj.add("Jesus", "Something", "Another") }
    end
    {"Darcy" => 6, "Bob" => 7, "Jesus" => 2, "Roflcopter" => 0}.each do |name, count|
      
      it "should have #{count} messages for #{name}" do
        Message.from(name).length.should == count
      end
      
      it "should have all Message for #{name}" do
        msgs = Message.from(name)
        msgs.inject(true) { |acc, current| acc && current.is_a?(Message) }.should == true
      end
      
      it "should have the messages for #{name} be in the correct order" do
        msgs = Message.from(name)
        msgs.sort_by { |m| m.created_at }.reverse.should == msgs
      end
      
    end
  end
  
  describe "Getting all replies to a specific user" do
    
    before :each do
      Message.drb_obj.add "Ninja", "rofl", "Darcy: Hello!"
      Message.drb_obj.add "Ninja", "rofl", "Darcy: Hello!"
      Message.drb_obj.add "Ninja", "rofl", "Darcy: Hello!"
      Message.drb_obj.add "Ninja", "rofl", "Darcy: Hello!"
      Message.drb_obj.add "Ninja", "rofl", "Jim: Hello!"
      Message.drb_obj.add "Ninja", "rofl", "Bob: Hello!"
      Message.drb_obj.add "Ninja", "rofl", "Bob: Hello!"
    end
    
    {"Darcy" => 4, "Jim" => 1, "Bob" => 2, "Ninjaman" => 0}.each do |name, count|
      
      it "should have #{count} messages for #{name}" do
        Message.replies_to(name).length.should == count
      end
      
      it "should be in the correct order for replies to #{name}" do
        msgs = Message.replies_to(name)
        msgs.sort_by { |m| m.created_at }.reverse.should == msgs
      end
      
    end
    
  end
  
  describe "Creating a message" do
    
    it "should require a from field" do
      Message.create(:contents => "Lulz").should == false
    end
    
    it "should require contents" do
      Message.create(:from => "SuttoL").should == false
    end
    
    it "should be created with the two aformentioned fields" do
      m = Message.create(:contents => "Ninjas", :from => "SuttoL")
      m.should_not == false
      m.is_a?(Message).should == true
      Message.all.first.should == m
    end
    
    it "should extract hash tags at the end after punctuation" do
      m = Message.create(:contents => "Ninjas!  #eotw", :from => "SuttoL")
      m.is_a?(Message).should == true
      m.contents.should == "Ninjas!"
      m.target.should   == "#eotw"
    end
    
    it "should use any other hashtag as a channel" do
      m = Message.create(:contents => "I can't believe I'm tweeting from #webjam", :from => "SuttoL")
      m.is_a?(Message).should == true
      m.contents.should == "I can't believe I'm tweeting from #webjam"
      m.target.should   == "#webjam"
    end
    
    it "should default back to #general if no hastag can be found" do
      m = Message.create(:contents => "Say hello to my little friend", :from => "SuttoL")
      m.is_a?(Message).should == true
      m.contents.should == "Say hello to my little friend"
      m.target.should   == "#general"
    end
    
  end
  
end
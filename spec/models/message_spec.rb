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
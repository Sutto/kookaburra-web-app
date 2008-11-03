require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Statuses, "index action" do
  before(:each) do
    dispatch_to(Statuses, :index)
  end
end
require 'spec_helper'
require 'diesel'

describe Diesel::APIBuilder do

  let(:specification) do
    Diesel.parse_specification(File.join(File.dirname(__FILE__), '..', 'files', 'pivotal_tracker.json'))
  end

  it "should build a API class from specification" do
    api = Diesel::APIBuilder.new(specification).build
  end

end

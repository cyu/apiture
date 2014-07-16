require 'spec_helper'

describe Diesel::APIBuilder do

  let(:api_declaration) do
    Diesel::JSONParser.new.parse_file(File.join(File.dirname(__FILE__), 'files', 'pivotal_tracker.json'))
  end

  it "should parse a JSON diesel specification" do
    api = Diesel::APIBuilder.new(api_declaration).build
  end

end

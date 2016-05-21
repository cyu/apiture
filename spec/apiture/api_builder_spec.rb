require 'spec_helper'
require 'apiture'

describe Apiture::APIBuilder do

  def build_spec(name)
    Apiture.parse_specification(File.join(File.dirname(__FILE__), '..', 'files', "#{name}.json"))
  end

  it "should build a API class from specification" do
    api = Apiture::APIBuilder.new(build_spec("pivotal_tracker")).build
    expect(api).to_not be_nil
  end

  it "should build a API class from specification" do
    api = Apiture::APIBuilder.new(build_spec("mandrill")).build
    expect(api).to_not be_nil
  end

end

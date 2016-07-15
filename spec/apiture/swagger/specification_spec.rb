require 'spec_helper'
require 'apiture/swagger/specification'

describe Apiture::Swagger::Specification do

  it "should serialize security node as key and scopes" do
    spec = described_class.new

    security = Apiture::Swagger::Security.new('oauth')
    security.scopes = ['email']
    spec.security = [security]

    h = spec.serializable_hash
    security_list = h['security'] 
    expect(security_list).to_not be_nil
    security = security_list.detect { |sec| sec.keys.first == 'oauth' }
    expect(security).to_not be_nil
    expect(security['oauth']).to eq ['email']
  end
end

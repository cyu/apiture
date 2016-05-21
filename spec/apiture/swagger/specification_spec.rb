require 'spec_helper'
require 'apiture/swagger/specification'

describe Apiture::Swagger::Specification do

  it "should serialize security node as key and scopes" do
    spec = described_class.new

    security = Apiture::Swagger::Security.new('oauth')
    security.scopes = ['email']
    spec.security = { 'oauth' => security }

    hash = spec.serializable_hash
    security_hash = hash['security'] 
    expect(security_hash).to_not be_nil
    scopes = security_hash['oauth']
    expect(scopes).to eq ['email']
  end
end

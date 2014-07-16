require 'spec_helper'

describe Diesel::JSONParser do

  it "should parse a JSON diesel specification" do
    api_decl = Diesel::JSONParser.new.parse_file(File.join(File.dirname(__FILE__), 'files', 'pivotal_tracker.json'))
    expect(api_decl).to_not be_nil

    expect(api_decl.description).to eq "PivotalTracker API v5"
    expect(api_decl.api_version).to eq "5"
    expect(api_decl.base_path).to eq "https://www.pivotaltracker.com/services/v5"

    api_token = api_decl.authorizations['apiToken']
    expect(api_token).to_not be_nil
    expect(api_token.type).to eq "apiKey"
    expect(api_token.pass_as).to eq "header"
    expect(api_token.keyname).to eq "X-TrackerToken"

    expect(api_decl.produces).to include "application/json"

    expect(api_decl.apis.count).to eq 1

    api = api_decl.apis.first
    expect(api).to_not be_nil
    expect(api.path).to eq "projects/{projectId}/stories"
    expect(api.description).to eq "Operations on stories"

    expect(api.operations.count).to eq 1

    op = api.operations.first
    expect(op).to_not be_nil
    expect(op.method).to eq "post"
    expect(op.nickname).to eq "createStory"

    expect(op.parameters.count).to eq 2

    param1 = op.parameters[0]
    expect(param1).to_not be_nil
    expect(param1.param_type).to eq "path"
    expect(param1.name).to eq "projectId"
    expect(param1).to be_required

    param2 = op.parameters[1]
    expect(param2).to_not be_nil
    expect(param2.param_type).to eq "body"
    expect(param2.name).to eq "body"
    expect(param2).to be_required
    expect(param2.type).to eq "NewStory"

    expect(api_decl.models.count).to eq 1

    model = api_decl.models["NewStory"]
    expect(model).to_not be_nil
    expect(model.id).to eq "NewStory"
    expect(model.required).to eq ["name"]

    expect(model.properties.count).to eq 15

    prop1 = model.properties["cl_numbers"]
    expect(prop1).to_not be_nil
    expect(prop1.type).to eq "string"

    prop2 = model.properties["current_state"]
    expect(prop2).to_not be_nil
    expect(prop2.type).to eq "string"
    expect(prop2.enum).to eq [
      "accepted",
      "delivered",
      "finished",
      "started",
      "rejected",
      "unstarted",
      "unscheduled"
    ]
  end
end

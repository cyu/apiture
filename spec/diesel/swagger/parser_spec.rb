require 'spec_helper'
require 'diesel/swagger/parser'

describe Diesel::Swagger::Parser do
  subject { Diesel::Swagger::Parser }

  let(:specification_json) do
    File.read(File.join(File.dirname(__FILE__), '..', '..', 'files', 'pivotal_tracker.json'))
  end

  it "should parse a diesel specification" do
    specification = Diesel::Swagger::Parser.new.parse(specification_json)
    expect(specification).to_not be_nil

    expect(specification.host).to eq "www.pivotaltracker.com"
    expect(specification.schemes).to include "https"
    expect(specification.base_path).to eq "/services/v5"

    expect(specification.info).to_not be_nil
    expect(specification.info.title).to eq "PivotalTracker"
    expect(specification.info.version).to eq "5"

    api_token = specification.security_definitions['apiToken']
    expect(api_token).to_not be_nil
    expect(api_token.type).to eq "apiKey"
    expect(api_token.in).to eq :header
    expect(api_token.name).to eq "X-TrackerToken"

    expect(specification.produces).to include "application/json"

    expect(specification.paths.count).to eq 1

    path = specification.paths["/projects/{projectId}/stories"]
    expect(path).to_not be_nil

    expect(path.post).to_not be_nil
    expect(path.post.operation_id).to eq "createStory"
    expect(path.post.external_docs.url).to eq "https://www.pivotaltracker.com/help/api/rest/v5#projects_project_id_stories_post"

    expect(path.post.parameters.count).to eq 2

    param1 = path.post.parameters[0]
    expect(param1).to_not be_nil
    expect(param1.in).to eq :path
    expect(param1.name).to eq "projectId"
    expect(param1).to be_required

    param2 = path.post.parameters[1]
    expect(param2).to_not be_nil
    expect(param2.in).to eq :body
    expect(param2.name).to eq "story"
    expect(param2).to be_required
    expect(param2.schema).to eq "NewStory"

    expect(specification.definitions.count).to eq 1

    definition = specification.definitions["NewStory"]
    expect(definition).to_not be_nil
    expect(definition.required).to eq ["name"]

    expect(definition.properties.count).to eq 15

    prop1 = definition.properties["cl_numbers"]
    expect(prop1).to_not be_nil
    expect(prop1.type).to eq :string

    prop2 = definition.properties["current_state"]
    expect(prop2).to_not be_nil
    expect(prop2.type).to eq :string
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

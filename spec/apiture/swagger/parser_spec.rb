require 'spec_helper'
require 'apiture/swagger/parser'

describe Apiture::Swagger::Parser do
  subject { Apiture::Swagger::Parser }

  def load_spec(name)
    File.read(File.join(File.dirname(__FILE__), '..', '..', 'files', "#{name}.json"))
  end

  it "should parse a swagger specification" do
    specification = Apiture::Swagger::Parser.new.parse(load_spec('pivotal_tracker'))
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

    security = specification.security.detect { |sec| sec.id == 'apiToken' }
    expect(security).to_not be_nil

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
    expect(param2.schema).to be_kind_of Apiture::Swagger::DefinitionReference
    expect(param2.schema.ref).to eq "#/definitions/NewStory"

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

  it "should parse a swagger specification with an array of schema objects" do
    specification = Apiture::Swagger::Parser.new.parse(load_spec('slack'))
    payload = specification.definitions["Payload"]

    attachments_prop = payload.properties['attachments']
    expect(attachments_prop.type).to eq :array
    expect(attachments_prop.definition).to be_kind_of Apiture::Swagger::ArrayDefinition
    expect(attachments_prop.definition.items).to be_kind_of Apiture::Swagger::DefinitionReference
  end

  it "should parse a swagger specification with operation specific security" do
    specification = Apiture::Swagger::Parser.new.parse(load_spec('github'))
    op = specification.paths["/applications/{clientId}/tokens/{accessToken}"].get
    expect(op.security.detect { |sec| sec.id == 'basic' }).to_not be_nil
  end

  it "should parse nested schema objects" do
    specification = Apiture::Swagger::Parser.new.parse(load_spec('mandrill'))
    op = specification.paths["/messages/send.json"].post
    request_param = op.parameters.first
    expect(specification.consumes).to include "application/json"
    expect(request_param.schema.class).to eq Apiture::Swagger::ObjectDefinition
  end

end

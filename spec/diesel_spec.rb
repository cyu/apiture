require 'spec_helper'
require 'diesel'
require 'logger'

describe Diesel do

  def configure_client(client)
    #client.logger = Logger.new(STDOUT)
    #client.logger.level = Logger::DEBUG
    client
  end

  def load_api(name)
    fn = File.join(File.dirname(__FILE__), 'files', "#{name}.json")
    Diesel.load_api(fn)
  end

  it "should be able to build a PivotalTracker API client" do
    PivotalTracker = load_api('pivotal_tracker')
    client = configure_client(PivotalTracker.new(api_token: 'afaketoken'))

    VCR.use_cassette('pivotal_tracker_create_story') do
      result = client.create_story(
        project_id: '1053124',
        story: {
          name: 'Testing Pivotal API',
          story_type: :chore
        })
      expect(result['kind']).to eq 'story'
      expect(result).to have_key('id')
      expect(result.response.code).to eq "200"
    end
  end

  it "should be able to build a Honeybadger API client" do
    Honeybadger = load_api('honeybadger')
    client = configure_client(Honeybadger.new(auth_token: 'afaketoken'))

    VCR.use_cassette('honeybadger') do
      results = client.get_faults(project_id: 3167)
      expect(results['results'].first).to have_key('project_id')
      expect(results.response.code).to eq "200"
    end
  end

  it "should be able to build a Slack API client" do
    Slack = load_api('slack')
    client = configure_client(Slack.new)

    VCR.use_cassette('slack') do
      results = client.post_message(path: 'abcd/efgh/ijkl',
                                    payload: {
                                      text: 'Testing',
                                      username: 'TestBot',
                                      attachments: [
                                        {
                                          fallback: "test fallback text",
                                          text: "test text",
                                          pretext: "test pretext",
                                          fields: [
                                            {
                                              title: "test field 1",
                                              value: "test value 1"
                                            },
                                            {
                                              title: "test field 2",
                                              value: "test value 2"
                                            }
                                          ]
                                        }
                                      ]
                                    })
      expect(results.response.code).to eq "200"
      expect(results.parsed_response).to eq "ok"
    end
  end

  it "should be able to call a zero parameter operation" do
    Github = load_api("github")
    client = configure_client(Github.new(oauth2: {token: "a19b557c75beed59278048da5acd20a17f77692e"}))

    VCR.use_cassette('github') do
      results = client.get_user
      expect(results.response.code).to eq "200"
      expect(results.parsed_response['login']).to eq "cyu"
    end
  end
end

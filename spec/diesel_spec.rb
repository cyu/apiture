require 'spec_helper'
require 'diesel'
require 'logger'

describe Diesel do

  def load_api(name)
    fn = File.join(File.dirname(__FILE__), 'files', "#{name}.json")
    Diesel.load_api(fn)
  end

  it "should be able to build a PivotalTracker API client" do
    PivotalTracker = load_api('pivotal_tracker')
    client = PivotalTracker.new(api_token: 'afaketoken')
    client.logger = Logger.new(STDOUT)
    client.logger.level = Logger::DEBUG

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
    client = Honeybadger.new(auth_token: 'afaketoken')
    client.logger = Logger.new(STDOUT)
    client.logger.level = Logger::DEBUG

    VCR.use_cassette('honeybadger') do
      results = client.get_faults(project_id: 3167)
      expect(results['results'].first).to have_key('project_id')
      expect(results.response.code).to eq "200"
    end
  end
end

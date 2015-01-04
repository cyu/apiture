require 'spec_helper'
require 'diesel'
require 'logger'

describe Diesel do
  it "should be able to build a working API client" do
    fn = File.join(File.dirname(__FILE__), 'files', 'pivotal_tracker.json')
    PivotalTracker = Diesel.load_api(fn)
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
      expect(result.response.code).to eq "200"
    end
  end
end

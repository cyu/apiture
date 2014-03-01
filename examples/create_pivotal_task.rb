require 'diesel'
require 'logger'
PivotalTracker = Diesel.load_api 'apis/pivotal_tracker'
api = PivotalTracker.new
api.logger = Logger.new(STDOUT)
api.logger.level = Logger::DEBUG
api.api_token = YOUR_API_TOKEN
p api.create_story(
  project_id: YOUR_PROJECT_ID,
  story: {
    name: 'Testing Pivotal API',
    :story_type => :chore
  })

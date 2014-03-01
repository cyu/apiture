require 'diesel'
require 'logger'

Slack = Diesel.load_api 'apis/slack'
api = Slack.new
api.logger = Logger.new STDOUT
api.api_token = YOUR_API_TOKEN
puts api.send_message(payload: {text: 'testing', channel: '#developers', username: 'calvin'})

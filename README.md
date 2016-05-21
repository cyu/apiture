# Apiture Gem

Create clients for REST APIs from their Swagger specification 

## Installation

Add this line to your application's Gemfile:

    gem 'apiture'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apiture

## Usage

```ruby
PivotalTracker = Apiture.load_api("pivotal_tracker.json")
client = PivotalTracker.new(api_token: 'afaketoken')
client.create_story(
  project_id: '1234567',
  story: {
    name: 'Testing Pivotal API',
    story_type: :chore
  })
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

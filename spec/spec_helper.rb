require 'bundler/setup'
Bundler.setup

require 'diesel'
require 'vcr'
require 'pry'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

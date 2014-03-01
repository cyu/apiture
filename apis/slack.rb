apis do
  description "Slack"
  api_version "1"
  base_path "https://scoutmob.slack.com/services/hooks"

  api_key "token" do
    nickname :api_token
    pass_as :query_parameter
  end

  header "Content-Type" => "application/json"

  resource "incoming-webhook" do
    description "Incoming Webhook"

    operation :send_message do
      reference_url "https://my.slack.com/services/new/incoming-webhook"
      method :post

      body "payload" do
        data_type "Payload"
      end
    end
  end

  complex_type "Payload" do
    required :text 
    property :text
    property :channel
    property :username
    property :icon_url
    property :icon_emoji
  end

end


apis do
  description "PivotalTracker API v5"
  api_version "5"
  base_path "https://www.pivotaltracker.com/services/v5"

  api_key "X-TrackerToken" do
    nickname :api_token
    pass_as :header
  end

  header "Content-Type" => "application/json"

  resource "projects/{project_id}/stories" do
    description "Operations on stories"

    operation :create_story do
      reference_url "https://www.pivotaltracker.com/help/api/rest/v5#projects_project_id_stories_post"
      method :post

      parameter "project_id" do
        param_type :path
        required true
      end

      body "story" do
        data_type "NewStory"
      end
    end
  end

  complex_type "NewStory" do
    required :name 
    property :cl_numbers
    property :current_state do
      enum :accepted, :delivered, :finished, :started, :rejected, :unstarted, :unscheduled
    end
    property :external_id
    property :deadline
    property :description
    property :estimate
    property :integration_id
    property :planned_iteration_number
    property :requested_by_id
    property :accepted_at
    property :before_id
    property :created_at
    property :after_id
    property :name
    property :story_type do
      enum :feature, :bug, :chore, :release
    end
  end

end

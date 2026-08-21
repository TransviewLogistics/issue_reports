require "spec_helper"

RSpec.describe ZendeskRailsS3TicketMaker::Maker do
  let(:fake_user) { OpenStruct.new(email: "user@example.com", id: 42, login: nil) }
  let(:fake_ticket) { OpenStruct.new(id: 999) }
  let(:fake_s3_client) { instance_double(Aws::S3::Client) }
  let(:fake_zendesk_client) { double("ZendeskAPI::Client") }
  let(:fake_tickets_collection) { double("tickets") }
  let(:screenshot_base64) { "data:image/png;base64,#{Base64.encode64('fakepng')}" }

  let(:config_options) do
    {
      instance_details: {
        description_column: :description,
        user_method: :user,
        screenshot_column: :screenshot,
        url_column: :url,
      },
      zendesk_details: {
        url: "https://example.zendesk.com/api/v2",
        ticket_url_prefix: "https://example.zendesk.com/agent/tickets",
        username: "test@example.com",
        token: "test-token",
      },
      ticket_details: {
        repo: "test_repo",
        labels: ["user_issue"],
        issue_title: "Found a bug",
      },
      s3_details: {
        bucket: "test-bucket",
        region: "us-east-1",
      },
    }.with_indifferent_access
  end

  let(:rails_config) do
    double(
      "rails_config",
      zendesk_rails_s3_ticket_maker_config_options: config_options,
      zendesk_rails_s3_ticket_maker_current_git_hash: "abc123"
    )
  end

  let(:rails_app) { double("rails_app", config: rails_config) }

  let(:model_class) do
    Class.new do
      include ZendeskRailsS3TicketMaker::Maker

      attr_accessor :id, :description, :screenshot, :url

      def initialize(attrs = {})
        attrs.each { |k, v| send(:"#{k}=", v) }
      end

      def user
        @user
      end

      def user=(val)
        @user = val
      end
    end
  end

  let(:instance) do
    obj = model_class.new(
      id: 1,
      description: "Something broke",
      screenshot: "data:image/png;base64,#{Base64.strict_encode64('fakepng')}",
      url: "http://example.com/page"
    )
    obj.user = fake_user
    obj
  end

  before do
    stub_const("Rails", double("Rails", application: rails_app))
    allow(Aws::S3::Client).to receive(:new).and_return(fake_s3_client)
    allow(fake_s3_client).to receive(:put_object)
    allow(ZendeskAPI::Client).to receive(:new).and_yield(
      double("zendesk_config").tap do |c|
        allow(c).to receive(:url=)
        allow(c).to receive(:username=)
        allow(c).to receive(:token=)
      end
    ).and_return(fake_zendesk_client)
    allow(fake_zendesk_client).to receive(:tickets).and_return(fake_tickets_collection)
    allow(fake_tickets_collection).to receive(:create!).and_return(fake_ticket)
  end

  describe "#create_zendesk_ticket" do
    it "uploads a screenshot to S3" do
      expect(fake_s3_client).to receive(:put_object).with(
        hash_including(bucket: "test-bucket", content_type: "image/png")
      )
      instance.create_zendesk_ticket
    end

    it "creates a Zendesk ticket with the configured subject and tags" do
      expect(fake_tickets_collection).to receive(:create!).with(
        hash_including(
          subject: "Found a bug",
          tags: ["user_issue"]
        )
      ).and_return(fake_ticket)
      instance.create_zendesk_ticket
    end

    it "returns a url built from the ticket id" do
      result = instance.create_zendesk_ticket
      expect(result[:url]).to eq("https://example.zendesk.com/agent/tickets/999")
      expect(result[:error]).to be_nil
    end

    it "returns an error and nil url when ZendeskAPI raises" do
      allow(fake_tickets_collection).to receive(:create!).and_raise(
        ZendeskAPI::Error::NetworkError.new("bad request")
      )
      result = instance.create_zendesk_ticket
      expect(result[:url]).to be_nil
      expect(result[:error]).to include("ZendeskAPI::Error")
    end

    it "returns an error and nil url when a StandardError is raised" do
      allow(fake_tickets_collection).to receive(:create!).and_raise(StandardError.new("unexpected failure"))
      result = instance.create_zendesk_ticket
      expect(result[:url]).to be_nil
      expect(result[:error]).to include("Unexpected error")
    end

    it "uses the external id from the model's id" do
      expect(fake_tickets_collection).to receive(:create!).with(
        hash_including(external_id: 1)
      ).and_return(fake_ticket)
      instance.create_zendesk_ticket
    end
  end
end

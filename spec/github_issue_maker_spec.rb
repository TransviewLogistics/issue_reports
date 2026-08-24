require "spec_helper"

RSpec.describe GithubIssueMaker do
  let(:config_options) do
    {
      instance_details: {
        description_column: :description,
        git_hash_column: :git_hash,
        screenshot_column: :screenshot,
        url_column: :url,
        user_method: :user
      },
      github_details: {
        access_token: "github-token",
        user: "owner",
        repo: "repo",
        labels: ["user_issue"],
        issue_title: "Found a bug"
      },
      s3_details: {
        bucket: "issue-screenshots",
        region: "us-east-1"
      }
    }
  end

  describe ".configuration" do
    it "raises a clear error when required settings are missing" do
      stub_const("GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG", github_details: { access_token: "token" })

      expect { described_class.configuration }
        .to raise_error(ArgumentError, /repository, issue_title, labels, s3_bucket, s3_region/)
    end

    it "loads the original configuration constant" do
      stub_const("GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG", config_options)

      expect(described_class.configuration.repository).to eq("owner/repo")
    end
  end

  describe GithubIssueMaker::Maker do
    let(:model_class) do
      Class.new do
        include GithubIssueMaker

        attr_accessor :description, :user, :git_hash, :screenshot, :url
      end
    end
    let(:user) { Struct.new(:email, :id).new("user@example.com", 42) }
    let(:issue_report) do
      model_class.new.tap do |report|
        report.description = "The route cannot be saved"
        report.user = user
        report.git_hash = "abc123"
        report.screenshot = "data:image/png;base64,aW1hZ2U="
        report.url = "https://example.com/routes/123"
      end
    end
    let(:s3_client) { instance_double(Aws::S3::Client) }
    let(:github_response) do
      instance_double(Net::HTTPResponse, code: "201", body: JSON.generate(html_url: "https://github.com/owner/repo/issues/123"))
    end

    before do
      stub_const("GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG", config_options)

      allow(SecureRandom).to receive(:hex).and_return("screenshot-key")
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    end

    it "uploads the screenshot, creates a GitHub issue, and returns the result" do
      expect(s3_client).to receive(:put_object).with(
        bucket: "issue-screenshots",
        acl: "public-read",
        key: "screenshot-key/issue.png",
        body: "image",
        content_type: "image/png"
      )

      expected_body = <<~BODY.strip
        # Description
        The route cannot be saved

        # User
        user@example.com - (42)

        # URL
        https://example.com/routes/123

        # Screenshot
        ![Issue](https://s3-us-east-1.amazonaws.com/issue-screenshots/screenshot-key/issue.png)

        # HEAD
        abc123
      BODY

      expect(Net::HTTP).to receive(:post).with(
        URI("https://api.github.com/repos/owner/repo/issues"),
        JSON.generate(title: "Found a bug", body: expected_body, labels: ["user_issue"]),
        {
          "Accept" => "application/vnd.github+json",
          "Authorization" => "Bearer github-token",
          "Content-Type" => "application/json",
          "User-Agent" => "github_issue_maker",
          "X-GitHub-Api-Version" => "2022-11-28"
        }
      ).and_return(github_response)

      expect(issue_report.create_github_issue).to eq(
        error: nil,
        url: "https://github.com/owner/repo/issues/123"
      )
    end

    it "returns a useful error when GitHub rejects the issue" do
      allow(s3_client).to receive(:put_object)
      response = instance_double(Net::HTTPResponse, code: "422", body: '{"message":"Validation Failed"}')
      allow(Net::HTTP).to receive(:post).and_return(response)

      expect(issue_report.create_github_issue).to eq(
        error: "GitHub issue creation failed (422): Validation Failed",
        url: nil
      )
    end

    it "returns unexpected errors instead of raising them" do
      allow(s3_client).to receive(:put_object).and_raise(StandardError, "S3 is unavailable")

      expect(issue_report.create_github_issue).to eq(
        error: "Unexpected error while trying to create GitHub issue. Error: S3 is unavailable",
        url: nil
      )
    end

    it "returns an error when the gem is not configured" do
      hide_const("GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG")

      expect(issue_report.create_github_issue).to eq(
        error: "GithubIssueMaker has not been configured",
        url: nil
      )
    end
  end
end

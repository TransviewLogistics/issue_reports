# Issue Reports Gem

Creates a GitHub issue from an issue-report model and uploads its PNG screenshot to S3. It calls GitHub's REST API directly, so it has no GitHub client dependency.

## Installation

```ruby
gem "github_issue_maker", git: "https://github.com/TransviewLogistics/issue_reports"
```

Include the maker in the issue-report model:

```ruby
class IssueReport < ApplicationRecord
  include GithubIssueMaker::Maker
end
```

## Configuration

Configure the required GitHub and S3 values explicitly in an initializer. This example loads them from [`config/github_issue_maker.yml`](./example/config/github_issue_maker.yml):

```ruby
settings = Rails.application.config_for(:github_issue_maker)

GithubIssueMaker.configure do |config|
  config.access_token = settings.fetch(:access_token)
  config.repository = settings.fetch(:repository)
  config.issue_title = settings.fetch(:issue_title)
  config.labels = settings.fetch(:labels)
  config.s3_bucket = settings.fetch(:s3_bucket)
  config.s3_region = settings.fetch(:s3_region)
end
```

`repository` must use the `owner/repository` format. The access token must be able to create issues in that repository.

By default, the model interface is `description`, `user`, `git_hash`, `screenshot`, and `url`. Override a method name when a model differs:

```ruby
GithubIssueMaker.configure do |config|
  # Required settings omitted for brevity.
  config.description_method = :report_text
  config.user_method = :reporter
  config.git_hash_method = :revision
  config.screenshot_method = :image_data
  config.url_method = :page_url
end
```

Call `create_github_issue!` on the model. It returns the new issue's HTML URL and raises `GithubIssueMaker::Error` if GitHub rejects the request.

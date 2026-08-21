# Issue Reports Gem

Creates a GitHub issue from an issue-report model and uploads its PNG screenshot to S3. It calls GitHub's REST API directly, so it has no GitHub client dependency.

## Installation

```ruby
gem "github_issue_maker", git: "https://github.com/TransviewLogistics/issue_reports"
```

Include the maker in the issue-report model:

```ruby
class IssueReport < ApplicationRecord
  include GithubIssueMaker
end
```

## Configuration

Define the original `github_issue_maker` configuration constant:

```ruby
GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG = {
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
    repo: "repository",
    labels: ["user_issue"],
    issue_title: "Found a bug"
  },
  s3_details: {
    bucket: "issue-screenshots",
    region: "us-east-1"
  }
}
```

The `user` and `repo` values identify the GitHub repository. The access token must be able to create issues in it. See [`config/github_issue_maker.yml`](./example/config/github_issue_maker.yml) for an environment-based example.

Call `create_github_issue!` on the model. It returns the new issue's HTML URL and raises `GithubIssueMaker::Error` if GitHub rejects the request.

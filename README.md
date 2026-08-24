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

The gem does not load a configuration file automatically. Define the settings in [`config/github_issue_maker.yml`](./example/config/github_issue_maker.yml), then load them into the original configuration constant from an initializer:

```ruby
GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG =
  Rails.application.config_for(:github_issue_maker)

Rails.application.config.current_git_hash = `git rev-parse HEAD`.chomp
```

The git hash setting is application configuration and is separate from the gem configuration. The `user` and `repo` values identify the GitHub repository. The access token must be able to create issues in it.

Call `create_github_issue` on the model. It returns `{ error: nil, url: "..." }` on success and `{ error: "...", url: nil }` if the issue cannot be created.

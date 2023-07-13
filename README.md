# Issue Reports Gem

Gem used to create tickets on ZenDesk from issue reports in a ruby on rails project. Uses S3 to upload a png for screenshots.

# Usage

## Installation and config

Add it to the Gemfile and run `bundle install`

Include the `IssueReports::Maker module inside your IssueReport model`

Add your `issue_reports.yml` config to `#{Rails.root}/config/issue_reports.yml}` [as in this example](./example/config/issue_reports.yml). You can use whatever environments you wish to use as the root level keys.
For the methods and columns, specify your own symbol that reflects your IssueReport model and schema.

You are all set!

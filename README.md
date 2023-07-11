Gem used to create tickets on ZenDesk from Issue Reports.

# Usage

## Define the following environment variables

- ZENDESK_URL
- ZENDESK_USERNAME
- ZENDESK_TOKEN
- ZENDESK_TICKET_URL_PREFIX

## Installation and config

Add it to the Gemfile and run `bundle install`

Add `require "issue_reports"` to the top of your `application.rb`

Include the `IssueReports::Maker module inside your IssueReport model`

Add your `issue_reports.yml` config to `#{Rails.root}/config/issue_reports.yml}` [as in this example](./example/config/issue_reports.yml). You can use whatever environments you wish to use as the root level keys.
For the methods and columns, specify your own symbol that reflects your IssueReport model and schema.

You are all set!

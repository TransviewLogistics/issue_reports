# Issue Reports Gem

Gem used to create tickets on ZenDesk from issue reports in a ruby on rails project. Uses S3 to upload a png for screenshots.

# Usage

## Installation and config

Add `gem "zendesk_rails_s3_ticket_maker", git: "https://github.com/TransviewLogistics/issue_reports"` to the Gemfile and run `bundle install`

Include the `ZendeskRailsS3TicketMaker::Maker module inside your IssueReport model`

Add your own `zendesk_rails_s3_ticket_maker.yml` config to `#{Rails.root}/config/zendesk_rails_s3_ticket_maker.yml}` [as in this example](./example/config/zendesk_rails_s3_ticket_maker.yml). You can use whatever environments you wish to use as the root level keys.
For the methods and columns, specify your own symbol that reflects your IssueReport model and schema.

You are all set!

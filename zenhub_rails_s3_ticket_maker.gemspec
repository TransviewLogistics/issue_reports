Gem::Specification.new do |s|
  s.name = "zenhub_rails_s3_ticket_maker"
  s.version = "1.0.0"
  s.summary = ""
  s.description = ""
  s.authors = ["HeadLight Solutions"]
  s.email = "contact@headlightsolutions.com"
  s.files = Dir.glob("**/*.rb")
  s.homepage = "https://github.com/TransviewLogistics/issue_reports"
  s.license = "MIT"
  s.add_runtime_dependency "rails", ">= 4.2"
  s.add_dependency "aws-sdk-core"
  s.add_dependency "aws-sdk-s3"
  s.add_dependency "zendesk_api", "~> 1.37"
  s.required_ruby_version = ">= 2.2.8"
end

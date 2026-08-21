Gem::Specification.new do |spec|
  spec.name = "github_issue_maker"
  spec.version = "1.0.0"
  spec.summary = "Creates GitHub issues from Rails issue reports"
  spec.authors = ["HeadLight Solutions"]
  spec.email = "contact@headlightsolutions.com"
  spec.files = Dir["lib/**/*.rb"]
  spec.homepage = "https://github.com/TransviewLogistics/issue_reports"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "rexml"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

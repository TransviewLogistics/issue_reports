require "aws-sdk-s3"
require "base64"
require "json"
require "net/http"
require "securerandom"
require "uri"

require_relative "github_issue_maker/configuration"

module GithubIssueMaker
  class Error < StandardError; end

  class << self
    def included(base)
      base.include(Maker)
    end

    def configuration
      return unless const_defined?(:GITHUB_ISSUE_MAKER_CONFIG, false)

      configuration = Configuration.new
      configuration.apply_options(const_get(:GITHUB_ISSUE_MAKER_CONFIG))
      configuration.validate!
    end
  end
end

require_relative "github_issue_maker/maker"

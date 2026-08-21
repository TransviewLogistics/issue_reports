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
    attr_reader :configuration

    def configure
      configuration = Configuration.new
      yield configuration
      configuration.validate!
      @configuration = configuration
    end
  end
end

require_relative "github_issue_maker/maker"

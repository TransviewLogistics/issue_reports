module GithubIssueMaker
  class Configuration
    REQUIRED_SETTINGS = %i[access_token repository issue_title labels s3_bucket s3_region].freeze
    REPOSITORY_PATTERN = %r{\A[^/\s]+/[^/\s]+\z}

    attr_accessor(*REQUIRED_SETTINGS)
    attr_accessor :description_method, :user_method, :git_hash_method, :screenshot_method, :url_method

    def initialize
      @description_method = :description
      @user_method = :user
      @git_hash_method = :git_hash
      @screenshot_method = :screenshot
      @url_method = :url
    end

    def validate!
      missing = REQUIRED_SETTINGS.select { |setting| blank?(public_send(setting)) }
      unless missing.empty?
        raise ArgumentError, "Missing GithubIssueMaker configuration: #{missing.join(", ")}"
      end

      unless repository.match?(REPOSITORY_PATTERN)
        raise ArgumentError, "GithubIssueMaker repository must use the owner/repository format"
      end

      self
    end

    private

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
  end
end

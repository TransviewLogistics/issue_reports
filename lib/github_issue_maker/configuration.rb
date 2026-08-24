module GithubIssueMaker
  class Configuration
    REQUIRED_SETTINGS = %i[access_token repository issue_title labels s3_bucket s3_region].freeze
    REPOSITORY_PATTERN = %r{\A[^/\s]+/[^/\s]+\z}

    attr_reader(*REQUIRED_SETTINGS)
    attr_reader :description_method, :user_method, :git_hash_method, :screenshot_method, :url_method

    def initialize
      self.description_method = :description
      self.user_method = :user
      self.git_hash_method = :git_hash
      self.screenshot_method = :screenshot
      self.url_method = :url
    end

    def apply_options(options)
      instance_details = option_group(options, :instance_details)
      github_details = option_group(options, :github_details)
      s3_details = option_group(options, :s3_details)

      self.description_method = option(instance_details, :description_column) || self.description_method
      self.user_method = option(instance_details, :user_method) || self.user_method
      self.git_hash_method = option(instance_details, :git_hash_column) || self.git_hash_method
      self.screenshot_method = option(instance_details, :screenshot_column) || self.screenshot_method
      self.url_method = option(instance_details, :url_column) || self.url_method

      self.access_token = option(github_details, :access_token)
      self.repository = repository_from(github_details)
      self.issue_title = option(github_details, :issue_title)
      self.labels = option(github_details, :labels)
      self.s3_bucket = option(s3_details, :bucket)
      self.s3_region = option(s3_details, :region)
      self
    end

    def validate!
      missing = REQUIRED_SETTINGS.select { |setting| blank?(public_send(setting)) }
      unless missing.empty?
        raise ArgumentError, "Missing GithubIssueMaker configuration: #{missing.join(", ")}"
      end

      unless self.repository.match?(REPOSITORY_PATTERN)
        raise ArgumentError, "GithubIssueMaker repository must use the owner/repository format"
      end

      self
    end

    private

    attr_writer(*REQUIRED_SETTINGS)
    attr_writer :description_method, :user_method, :git_hash_method, :screenshot_method, :url_method

    def option_group(options, name)
      option(options, name) || {}
    end

    def option(options, name)
      options[name] || options[name.to_s]
    end

    def repository_from(github_details)
      repository = option(github_details, :repository)
      return repository if repository

      user = option(github_details, :user)
      repo = option(github_details, :repo)
      "#{user}/#{repo}" if user && repo
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
  end
end

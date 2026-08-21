module GithubIssueMaker
  module Maker
    def create_github_issue!
      config = GithubIssueMaker.configuration
      raise Error, "GithubIssueMaker has not been configured" unless config

      screenshot_key = "#{SecureRandom.hex}/issue.png"
      upload_screenshot(screenshot_key, config)
      response = create_issue(screenshot_key, config)

      unless response.code.to_i.between?(200, 299)
        raise Error, "GitHub issue creation failed (#{response.code}): #{github_error_message(response.body)}"
      end

      JSON.parse(response.body).fetch("html_url")
    end

    private

    def upload_screenshot(screenshot_key, config)
      screenshot = public_send(config.screenshot_method)
      encoded_screenshot = screenshot.sub(/\Adata:image\/[^;]+;base64,/, "")

      Aws::S3::Client.new.put_object(
        bucket: config.s3_bucket,
        acl: "public-read",
        key: screenshot_key,
        body: Base64.decode64(encoded_screenshot),
        content_type: "image/png"
      )
    end

    def create_issue(screenshot_key, config)
      Net::HTTP.post(
        URI("https://api.github.com/repos/#{config.repository}/issues"),
        JSON.generate(title: config.issue_title, body: issue_body(screenshot_key, config), labels: config.labels),
        github_headers(config.access_token)
      )
    end

    def github_headers(access_token)
      {
        "Accept" => "application/vnd.github+json",
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json",
        "User-Agent" => "github_issue_maker",
        "X-GitHub-Api-Version" => "2022-11-28"
      }
    end

    def issue_body(screenshot_key, config)
      user = public_send(config.user_method)

      <<~BODY.strip
        # Description
        #{public_send(config.description_method)}

        # User
        #{user_identifier(user)} - (#{user_identifier(user, :id)})

        # URL
        #{public_send(config.url_method)}

        # Screenshot
        ![Issue](https://s3-#{config.s3_region}.amazonaws.com/#{config.s3_bucket}/#{screenshot_key})

        # HEAD
        #{public_send(config.git_hash_method)}
      BODY
    end

    def user_identifier(user, method = nil)
      return user.public_send(method) if method && user.respond_to?(method)
      return user.email if user.respond_to?(:email) && user.email
      return user.login if user.respond_to?(:login)
    end

    def github_error_message(response_body)
      JSON.parse(response_body).fetch("message", response_body)
    rescue JSON::ParserError
      response_body
    end
  end
end

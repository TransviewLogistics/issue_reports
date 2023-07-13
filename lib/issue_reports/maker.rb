module IssueReports
  module Maker
    require "aws-sdk-core"
    require "aws-sdk-s3"
    require "zendesk_api"

    def create_issue!
      file_name = "#{SecureRandom.uuid}/issue.png"

      create_s3_object(file_name)

      issue_body = issue_body(file_name)

      ticket = zendesk_client.tickets.create(
        subject: ticket_details[:issue_title],
        comment: { value: issue_body },
        tags: ticket_details[:labels],
        external_id: ticket_external_id,
      )

      unless ticket
        raise "Error while trying to create ZenDesk ticket."
      end

      "#{zendesk_details[:ticket_url_prefix]}/#{ticket.id}"
    end

    private

    def create_s3_object(file_name)
      s3 = Aws::S3::Client.new
      s3_body = decoded_issue_screenshot
      s3.put_object(bucket: s3_details[:bucket], acl: "public-read", key: file_name, body: s3_body, content_type: "image/png")
    end

    def decoded_issue_screenshot
      screenshot = self.send(instance_details[:screenshot_column])
      base_64_data_regex = /^data:image\/\w+;base64,/
      screenshot.gsub!(base_64_data_regex, '')
      Base64.decode64(screenshot)
    end

    def issue_body(screenshot_url)
      body = []
      body << "# Project \n #{ticket_details[:repo]}"
      body << "# Description \n #{description_section}"
      body << "# User \n #{user_section}"
      body << "# URL \n #{url_section}"
      body << "# Screenshot \n #{screenshot_section(screenshot_url)}"
      body << "# HEAD \n #{current_git_hash}"
      body.join("\n \n")
    end

    def description_section
      self.send(instance_details[:description_column])
    end

    def user_section
      user = self.send(instance_details[:user_method])
      "#{user.try(:email) || user.try(:login)} - (#{user.try(:id)})"
    end

    def url_section
      self.send(instance_details[:url_column])
    end

    def ticket_external_id
      self.send(:id)
    end

    def screenshot_section(screenshot_url)
      "![Issue](https://s3-#{s3_details[:region]}.amazonaws.com/#{s3_details[:bucket]}/#{screenshot_url})"
    end

    def current_git_hash
      @current_git_hash ||= Rails.application.config.issue_reports_current_git_hash
    end

    def instance_details
      @instance_details ||= Rails.application.config.issue_reports_config_options[:instance_details]
    end

    def ticket_details
      @ticket_details ||= Rails.application.config.issue_reports_config_options[:ticket_details]
    end

    def s3_details
      @s3_details ||= Rails.application.config.issue_reports_config_options[:s3_details]
    end

    def zendesk_details
      @zendesk_details ||= Rails.application.config.issue_reports_config_options[:zendesk_details]
    end

    def zendesk_client
      @zendesk_client || = ZendeskAPI::Client.new do |config|
        config.url = zendesk_details[:url]
        config.username = zendesk_details[:username]
        config.access_token = zendesk_details[:token]
      end
    end
  end
end

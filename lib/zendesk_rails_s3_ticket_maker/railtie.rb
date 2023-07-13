module ZendeskRailsS3TicketMaker
  class ZendeskRailsS3TicketMakerRailtie < Rails::Railtie
    initializer "zendesk_rails_s3_ticket_maker_railtie.config" do |app|
      config_options = YAML.load(ERB.new(File.read("#{Rails.root}/config/zendesk_rails_s3_ticket_maker.yml")).result).with_indifferent_access[Rails.env]
      app.config.zendesk_rails_s3_ticket_maker_config_options = config_options
      app.config.zendesk_rails_s3_ticket_maker_current_git_hash = `git rev-parse HEAD`.chomp
    end
  end
end

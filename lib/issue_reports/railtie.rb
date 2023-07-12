module IssueReports
  class IssueReportsRailtie < Rails::Railtie
    initializer "issue_reports_railtie.config" do |app|
      config_options = YAML.load(ERB.new(File.read("#{Rails.root}/config/issue_reports.yml")).result).with_indifferent_access[Rails.env]
      app.config.issue_reports_config_options = config_options
      app.config.issue_reports_current_git_hash = `git rev-parse HEAD`.chomp
    end
  end
end

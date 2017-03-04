require "docker_compose_deploy/version"

module DockerComposeDeploy
  class << self
    def configure
      yield(config_by_environment)
    end

    def config
      @config ||= Configuration.new(@environment, config_by_environment[@environment])
    end

    def configure!(environment)
      load('./config.rb')
      @environment = environment
    end

    private

    def config_by_environment
      @config_by_environment ||= {}
    end
  end

  class Configuration
    attr_reader :connection, :ignore_pull_failures
    def initialize(environment, connection:, ignore_pull_failures: false)
      @environment = environment
      @connection = connection
      @ignore_pull_failures = ignore_pull_failures
    end

    def sites_path
      File.join(".", environment, "sites")
    end
  end
end

require "docker_compose_deploy/version"
require "yaml"

module DockerComposeDeploy
  class << self
    def config
      @config || raise("Not configured")
    end

    def configure!(environment)
      yaml = YAML.load(File.read("./config.yml"))
      @config = Configuration.new(environment, yaml)
    end
  end

  class Configuration
    def initialize(environment, yaml)
      @environment = environment
      @yaml = yaml
    end

    def ignore_pull_failures
      config_block.fetch("ignore_pull_failures", false)
    end

    def connection
      config_block["connection"] || raise("INVALID CONFIG: Environment '#{@environment}' does not specify a connection string in config.yml")
    end

    def domains
      config_block.fetch("domains", [])
    end

    def stack?
      config_block.fetch("stack", false)
    end

    private

    def config_block
      @yaml[@environment] || raise("INVALID ENVIRONMENT: Environment '#{@environment}' is not configured in config.yml")
    end
  end
end

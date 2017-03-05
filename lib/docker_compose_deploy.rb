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
    attr_reader :connection, :ignore_pull_failures
    def initialize(environment, yaml)
      @connection = yaml.fetch(environment).fetch("connection")
      @ignore_pull_failures = yaml.fetch(environment).fetch("ignore_pull_failures", false)
    end
  end
end

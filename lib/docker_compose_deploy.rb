require "docker_compose_deploy/version"

module DockerComposeDeploy
  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure!
    load('./config.rb')
  end

  class Configuration
    attr_accessor :connection
    attr_accessor :ignore_pull_failures
  end
end

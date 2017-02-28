require "docker_compose_deploy/version"

module DockerComposeDeploy
  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure!
    # All paths relative to project root...because I feel like it...
    Dir.chdir(File.expand_path('..', __dir__))

    load('./config.rb')
  end

  class Configuration
    attr_accessor :connection
    attr_accessor :ignore_pull_failures
  end
end

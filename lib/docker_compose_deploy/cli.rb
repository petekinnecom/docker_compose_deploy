require "thor"
$LOAD_PATH.unshift(File.expand_path("..", __dir__))
require "docker_compose_deploy"
require "docker_compose_deploy/util/shell"
require "docker_compose_deploy/actions"

module DockerComposeDeploy
  class CLI < Thor
    desc "push IMAGE_NAME", "push IMAGE_NAME to configured host"
    option :e, required: true, default: "test"
    def push(image_name)
      DockerComposeDeploy.configure!(options[:e])
      Actions::Image.new(image_name, Util::Shell.new).push
    end

    desc "deploy", "deploy your docker-compose.yml to configured host"
    option :e, required: true, default: "test"
    def deploy
      DockerComposeDeploy.configure!(options[:e])
      ignore_pull_failures = DockerComposeDeploy.config.ignore_pull_failures
      shell = Util::Shell.new

      Actions::Deployment.new(ignore_pull_failures, shell).create

      if DockerComposeDeploy.config.test?
        Actions::Hosts.new(shell).hijack
      end
    end

    desc "backup", "backup the data directory of the configured host"
    option :e, required: true, default: "test"
    def backup
      DockerComposeDeploy.configure!(options[:e])
      Actions::Backup.new(Util::Shell.new).save
    end

    desc "provision", "provision the host to work with docker"
    option :e, required: true, default: "test"
    def provision
      DockerComposeDeploy.configure!(options[:e])
      Actions::Server.new(Util::Shell.new).provision
    end
  end
end

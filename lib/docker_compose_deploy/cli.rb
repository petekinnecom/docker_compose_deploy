require "thor"
$LOAD_PATH.unshift(File.expand_path("..", __dir__))
require "docker_compose_deploy"
require "docker_compose_deploy/util/shell"
require "docker_compose_deploy/actions"


module DockerComposeDeploy
  class CLI < Thor
    desc "push IMAGE_NAME", "push IMAGE_NAME to configured host"
    def push(image_name)
      DockerComposeDeploy.configure!
      Actions::Image.new(image_name, Util::Shell.new).push
    end

    desc "deploy", "deploy your docker-compose.yml to configured host"
    def deploy
      DockerComposeDeploy.configure!
      ignore_pull_failures = DockerComposeDeploy.config.ignore_pull_failures
      Actions::Deployment.new(ignore_pull_failures, Util::Shell.new).create
    end

    desc "backup", "backup the data directory of the configured host"
    def backup
      DockerComposeDeploy.configure!
      Actions::Backup.new(Util::Shell.new).save
    end

    desc "provision", "provision the host to work with docker"
    def provision
      DockerComposeDeploy.configure!
      Actions::Server.new(Util::Shell.new).provision
    end
  end
end

require "thor"
$LOAD_PATH.unshift(File.expand_path("..", __dir__))
require "docker_compose_deploy"
require "docker_compose_deploy/shell"
require "docker_compose_deploy/image_pusher"
require "docker_compose_deploy/deployer"
require "docker_compose_deploy/provisioner"
require "docker_compose_deploy/backup"

module DockerComposeDeploy
  class CLI < Thor
    desc "push IMAGE_NAME", "push IMAGE_NAME to configured host"
    def push(image_name)
      DockerComposeDeploy.configure!
      shell = Shell.new
      ImagePusher.new(image_name, shell).push
    end

    desc "deploy", "deploy your docker-compose.yml to configured host"
    def deploy
      DockerComposeDeploy.configure!
      shell = Shell.new
      ignore_pull_failures = DockerComposeDeploy.config.ignore_pull_failures
      Deployer.new(ignore_pull_failures, shell).deploy
    end

    desc "backup", "backup the data directory of the configured host"
    def backup
      DockerComposeDeploy.configure!
      Backup.new(Shell.new).save
    end

    desc "provision", "provision the host to work with docker"
    def provision
      DockerComposeDeploy.configure!
      Provisioner.new(Shell.new).provision
    end
  end
end

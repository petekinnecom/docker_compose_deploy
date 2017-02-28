require "docker_compose_deploy/shell"
require "docker_compose_deploy/docker_compose_file"

module DockerComposeDeploy
  class Deployer < Struct.new(:ignore_pull_failures, :shell)

    def self.deploy
      DockerComposeDeploy.configure!
      new(
        DockerComposeDeploy.config.ignore_pull_failures,
        Shell.new
      ).deploy
    end

    def deploy
      shell.ssh!("mkdir -p ./sites")
      shell.ssh!("rm -rf ./sites/config") # bin/deploy is irreversible :)
      shell.scp!("./sites/config/", "#{connection}:./sites/config", "-r")

      docker_compose.services.each do |service_name|
        shell.ssh!("mkdir -p ./sites/data/#{service_name}")
        shell.ssh!("mkdir -p ./sites/log/#{service_name}")
      end

      shell.scp!(docker_compose.path, "#{connection}:./docker-compose.yml")
      shell.ssh!("docker-compose down")
      shell.ssh!("docker-compose pull #{ignore_pull_failures_option}")
      shell.ssh!("docker-compose up -d")

      shell.notify "success"
    end

    private

    def ignore_pull_failures_option
      if ignore_pull_failures
        "--ignore-pull-failures"
      end
    end

    def docker_compose
      @docker_compose ||= DockerComposeFile.new
    end

    def connection
      DockerComposeDeploy.config.connection
    end
  end
end

require "docker_compose_deploy/actions/docker_compose/file"

module DockerComposeDeploy
  module Actions
    class Deployment < Struct.new(:ignore_pull_failures, :shell)

      def create
        shell.ssh!("mkdir -p ./sites")
        shell.ssh!("rm -rf ./sites/config") # bin/deploy is irreversible :)
        shell.scp!("./sites/config/", "#{connection}:./sites/config", "-r")

        docker_compose.services.each do |service_name|
          shell.ssh!("mkdir -p ./sites/config/#{service_name}")
          shell.ssh!("mkdir -p ./sites/data/#{service_name}")
          shell.ssh!("mkdir -p ./sites/log/#{service_name}")
        end

        if DockerComposeDeploy.config.stack?
          shell.scp!(docker_compose.path, "#{connection}:./docker-stack.yml")
          shell.ssh!("docker node ls || docker swarm init") # ensure a swarm is initialized
          shell.ssh!("docker stack rm dcd_stack || exit 0") # try to remove previous stack
          shell.ssh!("while docker ps | grep dcd > /dev/null; do echo 'waiting for shutdown' && sleep 1; done")
          shell.ssh!("docker stack deploy --compose-file docker-stack.yml dcd_stack")
        else
          shell.scp!(docker_compose.path, "#{connection}:./docker-compose.yml")
          shell.ssh!("docker-compose down")
          shell.ssh!("docker-compose pull #{ignore_pull_failures_option}")
          shell.ssh!("docker-compose up -d")
        end

        shell.notify "success"
      end

      private

      def ignore_pull_failures_option
        if ignore_pull_failures
          "--ignore-pull-failures"
        end
      end

      def docker_compose
        @docker_compose ||= DockerCompose::File.new
      end

      def connection
        DockerComposeDeploy.config.connection
      end
    end
  end
end

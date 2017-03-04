require "docker_compose_deploy/actions/docker_compose/file"

module DockerComposeDeploy
  module Actions
    class Deployment < Struct.new(:ignore_pull_failures, :shell)

      def create
        shell.ssh!("mkdir -p ./sites")
        shell.ssh!("rm -rf ./sites/config") # bin/deploy is irreversible :)
        shell.scp!(local_sites_path("config"), "#{connection}:./sites/config", "-r")

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
        @docker_compose ||= DockerCompose::File.new
      end

      def connection
        DockerComposeDeploy.config.connection
      end

      def local_sites_path(subdir)
        File.join(DockerComposeDeploy.config.sites_path, subdir)
      end
    end
  end
end

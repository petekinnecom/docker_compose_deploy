module DockerComposeDeploy
  module Actions
    class Server < Struct.new(:shell)

      def provision
        shell.notify("Provisioning: #{connection}")
        shell.ssh!("sudo groupadd docker")
        shell.ssh!("sudo usermod -aG docker $USER")
        shell.ssh!("true", "-O exit") # resets the connection, so that our group changes take effect

        shell.ssh!("wget -qO- https://get.docker.com/ | bash")
        shell.ssh!("curl -L https://github.com/docker/compose/releases/download/1.11.1/run.sh > ./docker-compose")
        shell.ssh!("chmod +x docker-compose")
        shell.ssh!("sudo mv ./docker-compose /usr/local/bin/docker-compose")
        shell.ssh!("docker-compose -v")

        shell.notify "success"
      end

      private

      def connection
        DockerComposeDeploy.config.connection
      end
    end
  end
end

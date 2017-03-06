module DockerComposeDeploy
  module Actions
    class Hosts < Struct.new(:shell)

      def hijack
        return unless DockerComposeDeploy.config.domains.any?

        shell.notify("Creating hosts entries for test_domains")

        host_entries = ["localhost", "vagrant"] + DockerComposeDeploy.config.domains
        Tempfile.open do |f|
          host_entries.each do |host|
            f.puts("127.0.0.1 #{host}")
          end
          f.close
          shell.scp!(f.path, "#{connection}:/tmp/hosts")
          shell.ssh!("sudo mv /tmp/hosts /etc/hosts")
          shell.notify("Wrote to /etc/hosts on test server:")
          shell.puts(`cat #{f.path}`)
        end
      end

      private

      def connection
        DockerComposeDeploy.config.connection
      end
    end
  end
end

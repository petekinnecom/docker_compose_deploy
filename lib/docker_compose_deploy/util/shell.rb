require 'docker_compose_deploy/util/color'

module DockerComposeDeploy
  module Util
    class Shell
      include Color

      def initialize
        $stderr.sync = true
        $stdout.sync = true
      end

      def run(cmd)
        puts blue(cmd)
        IO.popen(cmd) do |io|
          while (line = io.gets) do
            puts line
          end
        end
        $?
      end

      def run!(cmd)
        if run(cmd) != 0
          exit("\nCommand failed:\n#{cmd}")
        end
      end

      def warn(msg)
        puts red(msg)
      end

      def notify(msg)
        puts yellow(msg)
      end

      def puts(msg)
        Kernel.puts(msg)
      end

      def exit(msg)
        warn(msg)
        Kernel.exit(1)
      end

      def ssh(cmd)
        run(ssh_cmd(cmd))
      end

      def ssh!(cmd, opts="")
        run!(ssh_cmd(cmd, opts))
      end

      def scp!(src, dest, opts="")
        run!("scp -F ~/.ssh/config -F ssh_config_overrides #{opts} #{src} #{dest} > /dev/tty")
      end

      def confirm?(question)
        warn "#{question} [Yn]"
        STDIN.gets.strip.downcase != 'n'
      end

      def ssh_cmd(cmd, opts)
        "ssh -F ~/.ssh/config -F ssh_config_overrides #{opts} #{connection} '#{cmd}'"
      end

      private

      def connection
        DockerComposeDeploy.config.connection
      end
    end
  end
end

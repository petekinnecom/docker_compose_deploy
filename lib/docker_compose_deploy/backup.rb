module DockerComposeDeploy
  class Backup < Struct.new(:shell)

    def self.save
      DockerComposeDeploy.configure!
      new(Shell.new).save
    end

    def save
      shell.notify("Backing up remote ./sites/data directory")
      shell.notify("This may take a while...")
      shell.run!("mkdir -p ./backups")

      shell.ssh!("mkdir -p ./sites/backups")
      shell.ssh!("tar -zcvf ./sites/backups/#{filename} ./sites/data")
      shell.scp!("#{connection}:./sites/backups/#{filename}", "./backups/#{filename}")
      shell.ssh!("rm ./sites/backups/#{filename}")

      shell.notify "success"
    end

    private

    def tmp_dir
      @tmp_dir ||= "./tmp".tap do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def filename
      @filename ||= begin
        time_str = Time.now.strftime("%Y-%m-%d_%H.%M.%S")
        connection_str = DockerComposeDeploy.config.connection

        "backup__#{connection_str}__#{time_str}.tar.gz"
      end
    end

    def tmp_file_path
      File.join(tmp_dir, filename)
    end

    def connection
      DockerComposeDeploy.config.connection
    end
  end
end

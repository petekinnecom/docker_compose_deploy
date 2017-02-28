require "docker_compose_deploy/shell"
require "securerandom"
require "fileutils"

module DockerComposeDeploy
  class ImagePusher < Struct.new(:image_name, :shell)

    def self.push
      DockerComposeDeploy.configure!

      shell = Shell.new
      image_name = ARGV.first
      shell.exit("Provide an image name to push") unless image_name

      new(image_name, shell).push
    end

    def push
      shell.notify "Pushing #{image_name} to remote"

      shell.run!("docker save #{image_name} > #{tmp_file_path}")
      shell.run!("bzip2 #{tmp_file_path}")
      shell.scp!("#{tmp_file_path}.bz2", "#{connection}:/tmp/")
      shell.run!("rm #{tmp_file_path}.bz2")
      shell.ssh!("docker load -i /tmp/#{filename}.bz2")

      shell.notify "success"
    end

    private

    def tmp_dir
      @tmp_dir ||= "./tmp".tap do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def filename
      @filename ||= "#{image_name.gsub('/', '__')}_#{SecureRandom.hex}.tar"
    end

    def tmp_file_path
      File.join(tmp_dir, filename)
    end

    def connection
      DockerComposeDeploy.config.connection
    end
  end
end

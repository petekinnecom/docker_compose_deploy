module DockerComposeDeploy
  module Actions
    class Skeleton < Struct.new(:name, :shell)

      def create
        shell.notify("Creating new skeleton")
        if File.exist?(name)
          shell.warn("Directory or file: '#{name}' already exists. Exiting.")
          exit(1)
        end

        begin
          Dir.mkdir(name)
          Dir.rmdir(name)
        rescue
          shell.warn("Unable to make directory '#{name}'. Is it a valid directory name? Exiting.")
        end

        template_path = File.expand_path(File.join(__dir__, "../../../template"))
        FileUtils.cp_r(template_path, name)
        shell.notify("Created skeleton app in '#{name}'.")
        shell.puts <<-MESSAGE
To see the skeleton app in action, run the following commands

# Move into the directory
1. cd #{name}

# Use vagrant to create the virtual machine for testing (it will open a window and will display Ubuntu's desktop)
2. vagrant up

# Install docker and docker-compose on the vagrant machine
3. dcd provision

# Deploy the skeleton app to the vagrant machine
4. dcd deploy

# See the server in action:
5. Open firefox on the vagrant machine and visit http://www.test
        MESSAGE
      end
    end
  end
end

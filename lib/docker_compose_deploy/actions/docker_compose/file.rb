require 'yaml'

module DockerComposeDeploy
  module Actions
    module DockerCompose
      class File
        attr_reader :path
        def initialize(path="./docker-compose.yml")
          @path = path
        end

        def services
          if !hash["services"]
            raise "This is build to work with version 2 or 3 of docker-compose. It requires the 'services' top level key."
          end

          hash["services"].keys
        end

        private

        def hash
          @hash ||= YAML.load(string)
        end

        def string
          @string ||= ::File.read(@path)
        end
      end
    end
  end
end

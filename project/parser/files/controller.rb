require_relative './base'

module Stats
  module Project
    module Parser
      module Files
        class Controller < Base
          attr_accessor :repository, :root, :files, :except_files

          def initialize(repository)
            @repository = repository
            @except_files = ['application_controller.rb']
            @root = File.join(repository, 'app', 'controllers')
            @files = Dir["#{root}/**/*.rb"].collect { |file| File.basename(file) }
          end

          def concerns
            Dir["#{root}/concerns/**/*.rb"].collect { |file| File.basename(file) }
          end
        end
      end
    end
  end
end
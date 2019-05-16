require_relative './base'

module Stats
    module Parser
      module Files
        class Common < Base
          attr_accessor :repository, :root, :files, :except_files

          def initialize(repository)
            @repository = repository
            @except_files = []
            @root = repository
            @files = Dir["#{root}/**/*.rb"]#.collect { |file| File.basename(file) }
          end

          def concerns
            Dir["#{root}/concerns/**/*.rb"].collect { |file| File.basename(file) }
          end
        end
      end
    end
  end

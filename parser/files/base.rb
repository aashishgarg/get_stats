module Stats
  module Parser
    module Files
      class Base
        attr_accessor :repository

        def initialize(repository)
          @repository = repository
        end

        def root
          Dir.children(repository)
        end

        def folders
          Dir.glob(File.join(repository, "*", File::SEPARATOR)) #.collect {|s_d| File.basename(s_d) }
        end
      end
    end
  end
end

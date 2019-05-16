module Stats
  module Server
    class Files
      attr_accessor :repository

      def initialize(repository)
        @repository = repository
      end

      def all
        Dir["#{repository}/**/*.rb"] #.collect { |file| File.basename(file) }
      end
    end
  end
end
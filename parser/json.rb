require 'json'

module Stats
  module Parser
    class Json
      # --- Attribute Accessors --- #
      attr_accessor :json, :classes, :modules

      def initialize(source)
        @json = get_json(source)
        @temp_collection = []
        @classes = []
        @modules = []
      end

      def get_json(source)
        if source.is_a? Hash
          source
        elsif source.is_a?(String) && File.exist?(source)
          JSON.parse(File.read(source), { symbolize_names: true })
        else
          {}
        end
      end

      def processes
        json[:processes]
      end

      def repositories
        processes.collect{ |process| process[:repository][:root] }
      end

      def directories
        processes.collect do |process|
          {
              root: process[:repository][:root],
              files: process[:repository][:files],
          }
        end
      end

      def classes
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << {
                directory: dir[:root],
                classes: get_item(file[:hierarchy], 'class')
            }
          end
        end
        collection
      end

      def modules
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << {
                directory: dir[:root],
                classes: get_item(file[:hierarchy], 'module')
            }
          end
        end
        collection
      end

      def methods
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << {
                directory: dir[:root],
                classes: get_item(file[:hierarchy], 'method')
            }
          end
        end
        collection
      end

      def blocks
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << {
                directory: dir[:root],
                classes: get_item(file[:hierarchy], 'block')
            }
          end
        end
        collection
      end

      def model_classes

      end

      def controller_classes

      end

      def get_item(array, type)
        array.each do |hash|
          if hash[:type] == type
            @temp_collection << hash
            get_item(hash[:children], type)
          end
        end
        @temp_collection
      end
    end
  end
end
require 'byebug'
require 'json'
require_relative 'finder'

module Stats
  module Parser
    class Json
      # --- Attribute Accessors --- #
      attr_accessor :json, :temp_collection

      def initialize(source)
        @json = get_json(source)
        set_defaults
      end

      def set_defaults
        @temp_collection = []
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
        processes.collect { |process| { root: process[:repository][:root], files: process[:repository][:files] }}
      end

      def classes
        set_defaults
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << { directory: dir[:root], classes: get_item(file[:hierarchy], 'class') }
          end
        end
        collection.uniq
      end

      def modules
        set_defaults
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << { directory: dir[:root], modules: get_item(file[:hierarchy], 'module') }
          end
        end
        collection.uniq
      end

      def methods
        set_defaults
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << { directory: dir[:root], methods: get_item(file[:hierarchy], 'method') }
          end
        end
        collection.uniq
      end

      def blocks
        set_defaults
        collection = []
        directories.each do |dir|
          dir[:files].each do |file|
            collection << { directory: dir[:root], blocks: get_item(file[:hierarchy], 'block') }
          end
        end
        collection.uniq
      end

      def method_usages
        collection = []
        classes.each do |item|
          item[:classes].each do |_parent|
            (item[:classes] - [_parent]).each do |_child|
              _p_methods = _parent[:children].select{ |child| child[:type] == 'method' }
              _p_methods.each do |_method|
                collection << Stats::Parser::Finder.new.method(_method, _child)
              end
            end
          end
        end
        collection.reject(&:empty?)
      end



      def get_item(array, type)
        array = array.dup
        array.each do |hash|
          @temp_collection << hash if hash[:type] == type
          return temp_collection if hash[:children]
          get_item(hash[:children], type)
        end
        @temp_collection
      end
    end
  end
end

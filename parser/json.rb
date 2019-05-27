require 'byebug'
require 'json'
require_relative 'finder'

module Stats
  module Parser
    class Json
      # --- Attribute Accessors --- #
      attr_accessor :json, :temp_collection, :root

      def initialize(source, root)
        @json = get_json(source)
        @root = root
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

      def process
        json[:processes].select { |_process| _process[:repository][:root] == root }.last
      end

      def repository
        process[:repository]
      end

      def files
        repository[:files]
      end

      def _classes
        set_defaults
        collection = []
        files.each { |file| collection << get_item(file[:hierarchy], 'class') }
        collection.flatten.uniq
      end

      def _models
        _classes.select { |_class| _class[:file_type] == 'model' }
      end

      def _controllers
        _classes.select { |_class| _class[:file_type] == 'controller' }
      end

      def _modules
        set_defaults
        collection = []
        files.each { |file| collection << get_item(file[:hierarchy], 'module') }
        collection.flatten.uniq
      end

      def _methods
        set_defaults
        collection = []
        files.each { |file| collection << get_item(file[:hierarchy], 'method') }
        collection.flatten.uniq
      end

      def _blocks
        set_defaults
        collection = []
        files.each { |file| collection << get_item(file[:hierarchy], 'block') }
        collection.flatten.uniq
      end

      def method_usages
        collection = []
        _models.each do |_parent|
          _p_methods = _parent[:children].select{ |child| child[:type] == 'method' }
          _p_methods.each do |_method|
            (_classes - [_parent]).each do |_child|
              collection << Stats::Parser::Finder.new.method(_method, _child)
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

require 'byebug'
require_relative './regex'

module Stats
  module Parser
    class Finder
      include Stats::Parser::Regex
      attr_accessor :collection, :current_method, :target

      def initialize
        @collection = []
        @current_method = {}
        @target = {}
      end

      def association(_parent, _child, _association)
        hash = {
            parent: _parent,
            child: _child,
            usages: []
        }

        _child[:associations]
      end

      def method(_method, _target)
        @current_method, @target = _method, _target
        _method[:level] == 'instance' ? parse_instance_method : parse_class_method
        collection.map do
          {
              source_class: {name: current_method[:parent][-1][:name],id: current_method[:parent][-1][:id]},
              method: current_method[:name],
              consumer_class: {name: target[:name],id: target[:id]}
          }
        end
      end

      # Instance Method Rules ->
      #         1. [.method_name]
      def parse_instance_method
        if target[:body].any? {|line| line.scan(comment_regex).empty? && line.include?(".#{current_method[:name]}")}
          collection << current_method.dup
        end
      end

      # Class Method Rules ->
      #         1. [Classname.method_name]
      def parse_class_method
        _class_name = current_method[:parent][-1][:name]
        if target[:body].any? {|line| line.include?("#{_class_name}.#{current_method[:name]}")}
          collection << current_method.dup
        end
      end
    end
  end
end
require_relative './base'
require_relative './regex'

module Stats
  module Parser
    class Code < Base
      include Stats::Parser::Regex
      attr_accessor :hash, :current_file, :modules, :classes, :methods, :blocks, :type

      def initialize(current_file)
        @hash = {class: [], module: [], methods: [], blocks: [], validations: [], associations: [], constants: [] }
        @current_file = current_file
        @modules, @classes, @methods, @blocks, @type = [], [], [], [], ['public']
      end

      def process
        File.readlines(current_file).each do |line|
          next if module?(line)
          next if class?(line)
          next if model_class?(line) && validation?(line)
          next if model_class?(line) && association?(line)
          next if constant?(line)
          next if method_type?(line)
          next if method?(line)
          next if block?(line)
          next if end?(line)
        end
        hash
      end

      def model_class?(line)
        superclass(line).include?('ApplicationRecord') || !current_file.scan(/\/models\//).empty?
      end
    end
  end
end

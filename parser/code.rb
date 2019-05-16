require_relative './base'
require_relative './regex'

module Stats
  module Parser
    class Code < Base
      include Stats::Parser::Regex
      attr_accessor :current_file, :modules, :classes, :methods, :blocks, :hash, :type, :modules

      def initialize(current_file)
        @hash = {class: [], module: [], methods: [], blocks: []}
        @current_file = current_file
        @modules, @classes, @methods, @blocks, @type = [], [], [], [], ['public']
      end

      def process
        File.readlines(current_file).each do |line|
          next if module?(line)
          next if class?(line)
          next if method_type?(line)
          next if method?(line)
          next if block?(line)
          next if end?(line)
        end
        hash
      end
    end
  end
end
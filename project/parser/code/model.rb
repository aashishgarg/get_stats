require_relative './base'
require_relative '../../../project/parser/regex'

module Stats
  module Project
    module Parser
      module Code
        class Model < Base
          include Stats::Project::Parser::Regex
          attr_accessor :current_file,:modules, :classes, :methods, :blocks, :hash, :type, :modules

          def initialize(current_file)
            @hash = { class: [] }
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
              next if block_ended?(line)
              next if method_ended?(line)
              next if class_ended?(line)
              next if module_ended?(line)
            end
            hash
          end
        end
      end
    end
  end
end
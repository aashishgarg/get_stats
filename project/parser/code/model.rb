require_relative './base'

module Stats
  module Project
    module Parser
      module Code
        class Model < Base
          attr_accessor :current_file, :result, :class_regex, :superclass_regex, :method_regex

          def initialize(current_file)
            @current_file = current_file
            @result = { classes: {} }
            @class_regex = /(?<=class )\w+(?= <)/
            @superclass_regex = /(?<=< )\w+/
            @method_regex = /(?<=def )\w+/
          end

          def process_for_class
            File.readlines(current_file).each do |line|
              unless line.scan(class_regex).empty?
                class_name = line.scan(class_regex).flatten.first
                result[:classes][class_name] = {
                    superclass: line.scan(superclass_regex).flatten.first
                }
              end
            end
            result
          end

          def process_for_methods

          end
        end
      end
    end
  end
end
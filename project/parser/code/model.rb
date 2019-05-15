require_relative './base'

module Stats
  module Project
    module Parser
      module Code
        class Model < Base
          attr_accessor :current_file,
                        :comment_regex, :class_regex, :method_regex, :superclass_regex, :block_regex,
                        :class_end_regex, :method_end_regex, :block_end_regex,
                        :classes, :methods, :blocks,
                        :hash

          def initialize(current_file)
            @hash = { 'classes' => {} }
            @current_file = current_file
            @classes, @methods, @blocks = [], [], []
            @comment_regex = /^#/
            @class_regex = /\s*(?<=class)\s+(\w+)\s*/
            @class_end_regex = /^\s*end\s*$/
            @superclass_regex = /(?<=<)\s*(\w+)/
            @method_regex = /(?<=def)\s*\S+/
            @method_end_regex = /^\s*end\s*$/
            @block_regex = /\S+\s+do\s+\|\S+$/
            @block_end_regex = /^\s*end\s*$/
          end

          def process
            File.readlines(current_file).each do |line|
              next if class?(line)
              next if method?(line)
              next if block?(line)
              next if block_ended?(line)
              next if method_ended?(line)
              next if class_ended?(line)
            end
            hash
          end

          def comment?(line)
            !line.scan(comment_regex).empty?
          end

          def class?(line)
            scan = line.scan(class_regex).flatten.last&.strip
            if !comment?(line) && scan
              classes << scan
              hash['classes'][scan] = { 'methods' => {} }
            end
            scan
          end

          def method?(line)
            scan = line.scan(method_regex).last&.strip
            if !comment?(line) && scan
              methods << scan
              hash['classes'][classes.last]['methods'][scan] = { 'blocks' => [] }
            end
            scan
          end

          def block?(line)
            scan = line.scan(block_regex).last&.strip
            if !comment?(line) && scan
              blocks << scan
              hash['classes'][classes.last]['methods'][methods.last]['blocks'] << scan
            end
            scan
          end

          def block_ended?(line)
            scan = line.scan(block_end_regex).last&.strip
            blocks.pop if !comment?(line) && scan
            scan
          end

          def method_ended?(line)
            scan = line.scan(method_end_regex).last&.strip
            methods.pop if !comment?(line) && scan && !methods.empty?
            scan
          end

          def class_ended?(line)
            scan = line.scan(class_end_regex).last&.strip
            classes.pop if methods.empty? if !comment?(line) && scan && methods.empty?
            scan
          end
        end
      end
    end
  end
end
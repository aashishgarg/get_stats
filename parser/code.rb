require 'byebug'
require_relative './regex'

module Stats
  module Parser
    class Code
      include Stats::Parser::Regex
      attr_accessor :current_file, :scope, :level, :collection, :line, :hash, :body, :stack,
                    :class_started, :module_started

      def initialize(current_file)
        @current_file = current_file                  # File path under parsing
        @line = nil                                   # Current line under parsing
        @collection = [{children: []}]                # Final result collection
        @stack = []                                   # For tracking all the parents of a node
        @scope = ['public']                           # Scope of method(public/private/protected)
        @level = 1                                    # Nesting level of a node
        @hash = {associations: [], validations: []}   # Different Collections
        @body = []                                    # body of whole file
      end

      # -------------------------------- #
      # Ruby File Specific methods
      # -------------------------------- #
      def comment?
        !@line.scan(comment_regex).empty?
      end

      def module?
        scan = @line.scan(module_regex).last&.strip
        return unless scan

        item = {type: 'module', name: scan, id: id, node_level: @level, children: [], parent: @stack.dup, body: [line]}
        set_children(@collection, item, @level)
        @stack << {type: 'module', name: item[:name], id: item[:id]}
        @level += 1
      end

      def class?
        scan = @line.scan(class_regex).last&.strip
        return unless scan
        item = {type: 'class',
                name: scan,
                id: id,
                superclass: superclass,
                scope: @scope.last,
                file_type: file_type,
                node_level: @level
        }
        if file_type == 'model'
          item[:associations] = hash[:associations]
          item[:validations] = hash[:validations]
        end
        item[:children] = []
        # puts stack.to_s
        item[:parent] = @stack.dup
        item[:body] = [line]
        set_children(@collection, item, @level)
        @stack << {type: 'class', name: scan, id: item[:id]}
        @level += 1
      end

      def method?
        scan = @line.scan(method_regex).last&.strip
        return unless scan

        item = {}
        item[:type] = 'method'
        if scan.include?('self.')
          only_name = scan.delete(' ').split('self.').last.scan(method_name_regex).last&.strip
          args = scan.delete(' ').split('self.').last.scan(method_args_regex).last.strip.delete('()').split(',') rescue []
          item[:level] = 'class'
        else
          only_name = scan.delete(' ').scan(method_name_regex).last&.strip
          args = scan.delete(' ').scan(method_args_regex).last.strip.delete('()').split(',') rescue []
          item[:level] = 'instance'
        end
        item[:name] = only_name
        item[:id] = id
        item[:arguments] = args
        item[:node_level] = @level
        item[:children] = []
        item[:parent] = @stack.dup
        item[:body] = [line]

        set_children(@collection, item, @level)
        @stack << {type: 'method', name: scan, id: item[:id]}
        @level += 1
      end

      def method_type?
        scan = @line.scan(method_scope_regex).last&.strip
        @scope << scan if scan
      end

      def block?
        scan = @line.scan(block_regex).last&.strip
        scan ||= @line.scan(all_blocks_regex).last&.strip
        if scan
          item = {type: 'block', name: scan,id: id, node_level: @level, children: [], parent: @stack.dup, body: [line]}
          set_children(@collection, item, @level)
          @stack << {type: 'block', name: scan, id: item[:id]}
          @level += 1
        end
        scan
      end

      def end?
        scan = @line.scan(end_regex).last&.strip
        if scan
          @level -= 1
          stack.pop
        end
      end

      def superclass
        scan = @line.scan(superclass_regex).flatten.last&.strip
        scan || ''
      end

      def file_type
        model? || controller? || 'normal'
      end

      # -------------------------------- #
      # Controller Specific methods
      # -------------------------------- #
      def controller?
        'controller' if superclass.include?('ApplicationController')# || !current_file.scan(/\/controllers\//).empty?
      end

      # Model Specific methods
      #
      def model?
        'model' if superclass.include?('ApplicationRecord') || !current_file.scan(/\/models\//).empty?
      end

      def validation?
        scan = @line.scan(validation_regex).flatten.last&.strip
        hash[:validations] << scan if scan
        scan
      end

      def association?
        scan = line.scan(association_type_regex).flatten.last&.strip
        hash[:associations] << {
            type: scan,
            name: line.scan(association_name_regex).last&.strip,
            body: line
        } if scan
        scan
      end

      def constant?
        scan = line.scan(constant_regex).flatten.last&.strip
        hash[:constants] << scan if scan
      end

      # ----------------------------------------- #
      # Parses the file for different identifiers
      # ----------------------------------------- #
      def parse
        File.readlines(current_file).each do |_line|
          @body << @line = _line.chomp
          set_body(collection[-1][:children], _line)
          unless comment?
            next if module?
            next if class?
            next if association?
            next if validation?
            next if class?
            next if method_type?
            next if method?
            next if block?
            next if end?
          end

        end
        {body: @body, hierarchy: @collection[0][:children]}
      end

      private

      def set_children(array, value, counter)
        array = array.dup
        counter.times {array = array[-1][:children]}
        array << value
      end

      def set_body(array, line)
        array = array.dup
        (level-1).times do
          array[-1][:body] << line.chomp
          array = array[-1][:children]
        end
      end

      def id
        rand(100000000000)
      end
    end
  end
end

require_relative './regex'

module Stats
  module Parser
    class Code
      include Stats::Parser::Regex
      attr_accessor :current_file, :type, :level, :collection, :line, :hash

      def initialize(current_file)
        @current_file = current_file
        @scope = ['public']
        @level = 1
        @line = nil
        @collection = [{children: []}]
        @hash = { associations: [], validations: [] }
      end

      # Ruby File Specific methods
      #
      def comment?
        !@line.scan(comment_regex).empty?
      end

      def module?
        scan = @line.scan(module_regex).last&.strip
        return unless scan
        set_children(@collection, { type: 'module', name: scan, children: [] }, @level)
        @level += 1
      end

      def class?
        scan = @line.scan(class_regex).last&.strip
        return unless scan
        item = { type: 'class', name: scan,
                 superclass: superclass,
                 scope: @scope.last,
                 file_type: file_type
        }
        if file_type == 'model'
          item[:associations] = hash[:associations]
          item[:validations] = hash[:validations]
        end
        item[:children] = []
        set_children(@collection, item, @level)
        @level += 1
      end

      def method?
        scan = @line.scan(method_regex).last&.strip
        return unless scan
        set_children(@collection, { type: 'method', name: scan,children: [] }, @level)
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
          set_children(@collection, { type: 'block', name: scan, children: [] }, @level)
          @level += 1
        end
        scan
      end

      def end?
        scan = @line.scan(end_regex).last&.strip
        @level -= 1 if scan
      end

      def superclass
        scan = @line.scan(superclass_regex).flatten.last&.strip
        scan || ''
      end

      def file_type
        model? || controller? || 'normal'
      end

      # Controller Specific methods
      #
      def controller?
        'controller' if superclass.include?('ApplicationController') || !current_file.scan(/\/controllers\//).empty?
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
        scan = line.scan(association_regex).flatten.last&.strip
        hash[:associations] << scan if scan
        scan
      end

      def constant?
        scan = line.scan(constant_regex).flatten.last&.strip
        hash[:constants] << scan if scan
      end

      # Parses the file for different identifiers
      def parse
        File.readlines(current_file).each do |line|
          @line = line
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
        @collection[0][:children]
      end

      private


      def set_children(array, value, counter)
        array = array.dup
        (1..counter).each do |no|
          array = array[-1][:children]
        end
        array << value
      end
    end
  end
end

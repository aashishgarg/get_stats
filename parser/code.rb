require_relative './regex'

module Stats
  module Parser
    class Code
      include Stats::Parser::Regex
      attr_accessor :current_file, :type, :level, :collection, :line

      def initialize(current_file)
        @current_file = current_file
        @type = ['public']
        @level = 1
        @line = nil
        @collection = [{children: []}]
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
        hash = { type: 'class', name: scan,
                 superclass: superclass,
                 file_type: model? || controller? || 'File',
                 children: []
        }
        set_children(@collection, hash, @level)
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
        type << scan if scan
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
      end

      def association?
        scan = line.scan(association_regex).flatten.last&.strip
        hash[:associations] << scan if scan
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
            next if method?
            next if block?
            next if end?
          end
        end
        p @collection[0][:children]
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

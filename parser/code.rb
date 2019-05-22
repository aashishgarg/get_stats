require_relative './base'
require_relative './regex'

Hash.class_eval do
  def dig_fetch(*keys, last, &block)
    block ||= ->(*) { raise KeyError, "key not found: #{(keys << last).inspect}" }
    before = (keys.any? ? dig(*keys) || {} : self)
    before.fetch(last, &block)
  end

  def dig_set(keys, value, counter)
    raise ArgumentError, "No key given" if keys.empty?
    keys = keys.dup
    last = keys.pop
    failed = ->(*) { raise KeyError, "key not found: #{(keys << last).inspect}" }
    nested = keys.inject(self) { |h, k| h.fetch(k, &failed) }
    nested[last] << value
  end
end

module Stats
  module Parser
    class Code < Base
      include Stats::Parser::Regex
      attr_accessor :hash, :current_file, :modules, :classes, :methods, :blocks, :type, :stack, :level, :collection

      def initialize(current_file)
        @hash = {}
        @current_file = current_file
        @modules, @classes, @methods, @blocks, @type = [], [], [], [], ['public']
        @level = 1
        @stack = []
        @collection = [{children: []}]
      end
      # array = [{children: []}]
      # array = [{children: [
      #                      {type: 'class',name: 'A1', children: [
      #                                                            {type: 'method', name: 'aa', children: []}
      #                                                            {type: 'method', name: 'bb', children: []}
      #                                                           ]}
      #                     ]}]
      def set_children(array, value, counter)
        array = array.dup
        (1..counter).each do |no|
          array = array[-1][:children]
        end
        array << value
      end

      def module?(line)
        scan = line.scan(module_regex).flatten.last&.strip
        if !comment?(line) && scan
          set_children(@collection, { type: 'module', name: scan, children: [] }, @level)
          @level += 1
        end
        scan
      end

      def class?(line)
        scan = line.scan(class_regex).flatten.last&.strip
        if !comment?(line) && scan
          set_children(@collection, { type: 'class', name: scan, children: [] }, @level)
          @level += 1
        end
        scan
      end

      def method_type?(line)
        scan = line.scan(public_regex).last&.strip
        scan ||= line.scan(private_regex).last&.strip
        scan ||= line.scan(protected_regex).last&.strip
        type << scan if !comment?(line) && scan
        scan
      end

      def method?(line)
        scan = line.scan(method_regex).flatten.last&.strip
        if !comment?(line) && scan
          set_children(@collection, { type: 'method', name: scan, children: [] }, @level)
          @level += 1
        end
        scan
      end

      def block?(line)
        scan = line.scan(block_regex).last&.strip
        scan ||= line.scan(all_blocks_regex).last&.strip
        if !comment?(line) && scan
          set_children(@collection, { type: 'block', name: scan, children: [] }, @level)
          @level += 1
        end
        scan
      end

      def end?(line)
        scan = line.scan(end_regex).last&.strip
        if !comment?(line) && scan
          # puts '-------------------------'
          # puts @level
          @level -= 1
          # puts @level
        end
        scan
      end

      def process
        File.readlines(current_file).each do |line|
          next if module?(line)
          next if class?(line)
          next if method?(line)
          next if block?(line)
          next if end?(line)
        end
        p @collection
      end

      def model_class?(line)
        superclass(line).include?('ApplicationRecord') || !current_file.scan(/\/models\//).empty?
      end
    end
  end
end

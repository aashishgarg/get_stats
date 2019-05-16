require 'json'
require_relative '../server/base'
require_relative '../parser/code'
require_relative '../parser/files/common'

module Stats
  module Server
    class Instance < Base
      # --- Attribute Accessors --- #
      attr_accessor :pids, :sanitizer, :command, :result

      def initialize(pids, sanitizer, command, result)
        @pids, @sanitizer, @command, @result = pids, sanitizer, command, result
      end

      def build_result
        pids.each do |pid|
          root = sanitizer.repository_path(pid)
          common = Stats::Parser::Files::Common.new(root)
          result[:processes] << {
              pid: pid,
              port: sanitizer.port(pid),
              start_time: command.start_time(pid),
              repository: {root: root, directories: process(common.files)}
          }
        end
      end

      def process(files)
        result = []
        files.each do |file|
          hash = Stats::Parser::Code.new(file).process
          result << {
              dir: File.dirname(file),
              path: file,
              file_name: file_name(file),
              class: hash[:class],
              module: hash[:module]
          }
        end
        result
      end

      def print_result(path)
        File.open(path, 'w') {|f| f.write(JSON.pretty_generate(result))}
      end

      def repositories
        result[:processes].collect {|process| process[:repository]}.uniq.reject {|x| x.empty?}
      end
    end
  end
end

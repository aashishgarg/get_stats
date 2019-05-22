require 'json'
require_relative './files'
require_relative '../parser/code'

module Stats
  module Server
    class Instance
      # --- Attribute Accessors --- #
      attr_accessor :pids, :sanitizer, :command, :result

      def initialize(pids, sanitizer, command, result)
        @pids, @sanitizer, @command, @result = pids, sanitizer, command, result
      end

      def build_result
        pids.each do |pid|
          root = sanitizer.repository_path(pid)
          result[:processes] << {
              pid: pid,
              port: sanitizer.port(pid),
              start_time: command.start_time(pid),
              repository: {root: root, directories: process(Stats::Server::Files.new(root).all)}
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
              file_name: File.basename(file, '.rb'),
              child: hash
              # class: hash[:class],
              # module: hash[:module],
              # validations: hash[:validations],
              # associations: hash[:associations],
              # constants: hash[:constants]
          }
        end
        result
      end

      def print_result(path)
        File.open(path, 'w') {|f| f.write(JSON.pretty_generate(result))}
      end

      def repositories
        result[:processes].collect {|process| process[:repository]}.uniq.reject(&:empty?)
      end
    end
  end
end

require 'json'
require_relative './files'
require_relative '../parser/code'
require_relative '../parser/meta'

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
              repository: {
                  root: root,
                  structure: Stats::Parser::Meta.structure,
                  files: process(Stats::Server::Files.new(root).all),
              }
          }
        end
      end

      def process(files)
        result = []
        # files = files.select {|x| x.include?('/lab.rb') || x.include?('/lab_test.rb') }
        files.each do |file|
          hash = Stats::Parser::Code.new(file).parse
          result << {
              dir: File.dirname(file),
              path: file,
              file_name: File.basename(file, '.rb'),
              hierarchy: hash[:hierarchy],
              body: hash[:body]
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

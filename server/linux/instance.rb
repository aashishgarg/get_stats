require 'json'
require_relative './base'

module Stats
  module Server
    module Linux
      class Instance < Base
        # --- Attribute Accessors --- #
        attr_accessor :pids, :command, :sanitizer

        def initialize(pids, sanitizer, command, result)
          @pids = pids
          @sanitizer = sanitizer
          @command = command
          @result = result
        end

        def build_result
          pids.each do |pid|
            result[:processes] << {
                pid: pid,
                port: command.port(pid),
                repository: sanitizer.repository_path(pid),
                start_time: command.start_time(pid)
            }
          end
        end

        def print_result
          File.open("/home/ubuntu/result.json", 'w') {|f| f.write(JSON.pretty_generate(result)) }
        end
      end
    end
  end
end
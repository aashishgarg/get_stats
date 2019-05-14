require_relative './base'

module Stats
  module Server
    module Linux
      class Sanitizer < Base
        attr_accessor :command

        def initialize(command)
          @command = command
        end

        def repository_path(pid)
          command.repository(pid).delete(pid).delete("\n").delete(' :')
        end

        def processes(string)
          string.split("\n").collect {|pair| pair.split(' ')}
        end

        def perform(string)
          string.delete("\n")
        end

        def redis_pids
          command.redis_pids.split("\n").collect{ |x| x.split(':') }.collect(&:last).uniq
        end

        def server_pids
          command.server_pids.split("\n")
        end
      end
    end
  end
end
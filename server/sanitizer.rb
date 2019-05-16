require_relative './base'

module Stats
  module Server
    class Sanitizer < Base
      attr_accessor :command

      def initialize(command)
        @command = command
      end

      def repository_path(pid)
        command.repository(pid).delete("\n").split("#{pid}: ").last
      end

      def processes(string)
        string.split("\n").collect {|pair| pair.split(' ')}
      end

      def perform(string)
        string.delete("\n")
      end

      def redis_pids
        command.redis_pids.split("\n").collect {|x| x.split(':')}.collect(&:last).uniq
      end

      def server_pids
        command.server_pids.split("\n")
      end

      def port(pid)
        command.port(pid).split("\n").collect {|x| x.split(':')}.collect(&:last).last
      end
    end
  end
end

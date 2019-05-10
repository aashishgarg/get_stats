require_relative './base'
require_relative './server/linux/instance'
require_relative './server/linux/command'
require_relative './server/linux/sanitizer'

module Stats
  class Instance < Base
    # --- Attribute Accessors
    attr_accessor :processes, :server, :result, :repositories, :ports, :pids, :release, :command, :sanitizer

    def initialize(type)
      @command = get_command_obj
      @processes = command.active_processes
      @sanitizer = get_sanitizer_obj
      @release = command.release
      @result = { server_release: sanitizer.perform(release), processes: [] }
      @server = get_instance(type)
      @server.build_result if server
    end

    def get_instance(type)
      instance_type = type == 'Linux' ? Server::Linux::Instance : nil
      instance_type.nil? ? nil : instance_type.new(processes, sanitizer, command, result)
    end

    def get_command_obj
      Server::Linux::Command.new
    end

    def get_sanitizer_obj
      Server::Linux::Sanitizer.new
    end
  end
end
require_relative './base'
require_relative './server/linux/instance'
require_relative './server/linux/command'
require_relative './server/linux/sanitizer'

module Stats
  class Instance < Base
    # --- Attribute Accessors
    attr_accessor :server, :result

    def initialize(type)
      @command = get_command_obj
      @processes = command.active_processes
      @sanitizer = get_sanitizer_obj
      @release = command.release
      @result = { server_release: sanitizer.perform(release), processes: [] }
      @server = get_instance
      @server.build_result
    end

    def get_instance
      Server::Linux::Instance.new(processes, sanitizer, command, result)
    end

    def get_command_obj
      Server::Linux::Command.new
    end

    def get_sanitizer_obj
      Server::Linux::Sanitizer.new
    end
  end
end
#!/usr/bin/env ruby

require_relative './base'
require_relative './server/linux/instance'
require_relative './server/linux/command'
require_relative './server/linux/sanitizer'

module Stats
  class Instance < Base
    # --- Attribute Accessors
    attr_accessor :ask_pass_path, :server, :result, :pids, :command, :sanitizer

    def initialize(type, ask_pass_path = nil)
      @ask_pass_path = ask_pass_path
      @command = get_command_obj
      @sanitizer = get_sanitizer_obj
      @pids = [sanitizer.server_pids, sanitizer.redis_pids].flatten.uniq
      @result = { server_release: sanitizer.perform(command.os_release), processes: [] }
      @server = get_instance(type)
      server.build_result if server
      server.print_result if server
    end

    def get_instance(type)
      instance_type = type == 'Linux' ? Server::Linux::Instance : nil
      instance_type.nil? ? nil : instance_type.new(pids, sanitizer, command, result)
    end

    def get_command_obj
      Server::Linux::Command.new(ask_pass_path)
    end

    def get_sanitizer_obj
      Server::Linux::Sanitizer.new(command)
    end
  end
end

Stats::Instance.new('Linux', "/home/ubuntu/SudoPass.sh")
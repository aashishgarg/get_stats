#!/usr/bin/env ruby

require_relative './server/instance'
require_relative './server/command'
require_relative './server/sanitizer'

module Stats
  class Extract
    # --- Attribute Accessors
    attr_accessor :ask_pass_path, :server, :result, :pids, :command, :sanitizer, :result_path

    def initialize(type, ask_pass_path = nil)
      @ask_pass_path = ask_pass_path
      @result_path = File.join(File.dirname(__FILE__), 'result.json')
      @command = get_command_obj
      @sanitizer = get_sanitizer_obj
      @pids = [sanitizer.server_pids, sanitizer.redis_pids].flatten.uniq
      @result = { server_release: sanitizer.perform(command.os_release), processes: [], errors: [] }
      @server = get_instance(type)
      start if server
    end

    def get_instance(type)
      instance_type = type == 'Linux' ? Server::Instance : nil
      instance_type.nil? ? nil : instance_type.new(pids, sanitizer, command, result)
    end

    def get_command_obj
      Server::Command.new(ask_pass_path)
    end

    def get_sanitizer_obj
      Server::Sanitizer.new(command)
    end

    def start
      begin
        server.build_result
        server.print_result(result_path)
      rescue StandardError => e
        result[:errors] << { message: e.message, trace: e.trace }
      end
    end
  end
end

Stats::Extract.new('Linux', "/home/ubuntu/SudoPass.sh")
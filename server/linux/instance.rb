require 'json'
require_relative './base'

module Stats
  module Server
    module Linux
      class Instance < Base
        # --- Attribute Accessors --- #
        attr_accessor :pids, :command, :sanitizer, :result_file

        def initialize(pids, sanitizer, command, result)
          @pids = pids
          @sanitizer = sanitizer
          @command = command
          @result = result
          @result_file = '/home/ubuntu/result.json'
        end

        def build_result
          pids.each do |pid|
            root = sanitizer.repository_path(pid)
            model = Stats::Project::Parser::Model.new(root)
            controller = Stats::Project::Parser::Controller.new(root)

            result[:processes] << {
                pid: pid,
                port: sanitizer.port(pid),
                repository: {
                    root: root,
                    files: {
                        model: model.main_files(model.except_files),
                        controller: controller.main_files(controller.except_files)
                    }
                },
                start_time: command.start_time(pid)
            }
          end
        end

        def print_result
          File.open(result_file, 'w') {|f| f.write(JSON.pretty_generate(result)) }
        end

        def repositories
          result[:processes].collect{ |process| process[:repository] }.uniq.reject{|x| x.empty?}
        end
      end
    end
  end
end
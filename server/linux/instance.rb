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
            model = Stats::Project::Parser::Files::Model.new(root)
            controller = Stats::Project::Parser::Files::Controller.new(root)

            result[:processes] << {
                pid: pid,
                port: sanitizer.port(pid),
                repository: {
                    root: root,
                    directories: {
                        model: process_models(model.files),
                        controller: process_controllers(controller.files)
                    }
                },
                start_time: command.start_time(pid)
            }
          end
        end

        def process_models(models)
          result = {}
          models.each do |model|
            hash = Stats::Project::Parser::Code::Model.new(model).process
            result[model] = {
                name: file_name(model),
                classes: hash['classes']
            }
          end
          result
        end

        def process_controllers(controllers)
          result = {}
          controllers.each do |controller|
            result[controller] = {
                name: file_name(controller)
            }
          end
          result
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

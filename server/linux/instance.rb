require 'json'
require_relative './base'
require_relative '../../project/parser/code/model'
require_relative '../../project/parser/code/controller'
require_relative '../../project/parser/code/common'
require_relative '../../project/parser/files/common'

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
            root = sanitizer.repository_path(pid)
            model = Stats::Project::Parser::Files::Model.new(root)
            controller = Stats::Project::Parser::Files::Controller.new(root)
            common = Stats::Project::Parser::Files::Common.new(root)
            result[:processes] << {
                pid: pid,
                port: sanitizer.port(pid),
                repository: {
                    root: root,
                    directories: {
                        models: process_models(model.files),
                        controllers: process_controllers(controller.files),
                        common: process_common(common.files),
                    }
                },
                start_time: command.start_time(pid)
            }
          end
        end

        def process_common(files)
          result = []
          files.each do |file|
            hash = Stats::Project::Parser::Code::Model.new(file).process
            result << {
                path: file,
                file_name: file_name(file),
                class: hash[:class],
                module: hash[:module]
            }
          end
          result
        end

        def process_models(models)
          result = []
          models.each do |model|
            hash = Stats::Project::Parser::Code::Model.new(model).process
            result << {
                path: model,
                file_name: file_name(model),
                class: hash[:class],
                module: hash[:module]
            }
          end
          result
        end

        def process_controllers(controllers)
          result = []
          controllers.each do |controller|
            hash = Stats::Project::Parser::Code::Model.new(controller).process
            result << {
                path: controller,
                file_name: file_name(controller),
                class: hash[:class]
            }
          end
          result
        end

        def print_result
          File.open(File.join(File.dirname(__FILE__), '../../', 'result.json'), 'w') {|f| f.write(JSON.pretty_generate(result)) }
        end

        def repositories
          result[:processes].collect{ |process| process[:repository] }.uniq.reject{|x| x.empty?}
        end
      end
    end
  end
end

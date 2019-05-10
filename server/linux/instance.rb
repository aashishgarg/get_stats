module Stats
  module Server
    module Linux
      class Instance
        # --- Attribute Accessors --- #
        attr_accessor :processes, :sanitizer, :pids, :ports, :repositories, :command, :result

        def initialize(processes, sanitizer, command, result)
          @pids = []
          @ports = []
          @repositories = []
          @processes = processes
          @sanitizer = sanitizer
          @command = command
          @result = result
        end

        def build_result
          nested_array = sanitizer.processes(processes)
          nested_array.each do |array|
            pid, port = *array
            pids << pid
            ports << port
            repositories << command.repository(pid)
            result[:processes] << {
                pid: pid,
                port: port,
                repository: sanitizer.repository_path(command.repository(pid), pid),
                start_time: command.start_time(pid)
            }
          end
        end
      end
    end
  end
end
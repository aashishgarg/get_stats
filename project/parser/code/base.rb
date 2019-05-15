module Stats
  module Project
    module Parser
      module Code
        class Base
          def comment?(line)
            !line.scan(comment_regex).empty?
          end

          def module?(line)
            scan = line.scan(class_regex).flatten.last&.strip
            if !comment?(line) && scan
              classes << scan
              hash[:class][scan] = { superclass: superclass(line), methods: {} }
            end
            scan
          end

          def class?(line)
            scan = line.scan(class_regex).last&.strip
            if !comment?(line) && scan
              classes << scan
              hash[:class] << { name: scan, superclass: superclass(line), methods: [] }
            end
            scan
          end

          def method_type?(line)
            scan = line.scan(public_regex).last&.strip
            scan ||= line.scan(private_regex).last&.strip
            scan ||= line.scan(protected_regex).last&.strip
            if !comment?(line) && scan
              type << scan
            end
            scan
          end

          def method?(line)
            scan = line.scan(method_regex).last&.strip
            if !comment?(line) && scan
              methods << scan
              hash[:class][-1][:methods] << {
                  name: scan,
                  type: type[-1],
                  blocks: [] }
            end
          end

          def block?(line)
            scan = line.scan(block_regex).last&.strip
            if !comment?(line) && scan
              blocks << scan
              hash[:class][-1][:methods][-1][:blocks] << scan
            end
          end

          def block_ended?(line)
            scan = line.scan(block_end_regex).last&.strip
            blocks.pop if !comment?(line) && scan
            scan
          end

          def method_ended?(line)
            scan = line.scan(method_end_regex).last&.strip
            methods.pop if !comment?(line) && scan && !methods.empty?
            scan
          end

          def class_ended?(line)
            scan = line.scan(class_end_regex).last&.strip
            classes.pop if methods.empty? if !comment?(line) && scan && methods.empty?
            scan
          end

          def superclass(line)
            scan = line.scan(superclass_regex).flatten.last&.strip
            scan || ''
          end
        end
      end
    end
  end
end
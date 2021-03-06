module Stats
  module Parser
    class Base
      def comment?(line)
        !line.scan(comment_regex).empty?
      end

      def module?(line)
        scan = line.scan(module_regex).flatten.last&.strip
        if !comment?(line) && scan
          modules << scan
          hash[:module] << {name: scan, methods: []}
        end
        scan
      end

      def class?(line)
        unless comment?(line)
          scan = line.scan(class_regex).last&.strip
          if scan
            classes << scan
            hash[:class] << {name: scan, superclass: superclass(line), module: (modules[-1] || ''), methods: []}
          end
          scan
        end
      end

      def method_type?(line)
        scan = line.scan(public_regex).last&.strip
        scan ||= line.scan(private_regex).last&.strip
        scan ||= line.scan(protected_regex).last&.strip
        type << scan if !comment?(line) && scan
        scan
      end

      def method?(line)
        scan = line.scan(method_regex).last&.strip
        if !comment?(line) && scan
          methods << scan
          if classes.empty?
            if modules.empty?
              hash[:methods] << {name: scan, type: type[-1], blocks: []}
            else
              hash[:module][-1][:methods] << {name: scan, type: type[-1], blocks: []}
            end
          else
            hash[:class][-1][:methods] << {name: scan, type: type[-1], blocks: []}
          end
        end
        scan
      end

      def block?(line)
        scan = line.scan(block_regex).last&.strip
        scan ||= line.scan(all_blocks_regex).last&.strip
        if !comment?(line) && scan
          blocks << scan
          if classes.empty?
            if modules.empty?
              methods.empty? ? hash[:blocks] << scan : hash[:methods][-1][:blocks] << scan
            else
              methods.empty? ? hash[:blocks] << scan : hash[:modules][-1][:methods][-1][:blocks] << scan
            end
          else
            methods.empty? ? hash[:blocks] << scan : hash[:class][-1][:methods][-1][:blocks] << scan
          end
        end
        scan
      end

      def end?(line)
        scan = line.scan(end_regex).last&.strip
        if !comment?(line) && scan
          return blocks.pop unless blocks.empty?
          return methods.pop unless methods.empty?
          return classes.pop unless classes.empty?
          return modules.pop unless modules.empty?
        end
        scan
      end

      def superclass(line)
        scan = line.scan(superclass_regex).flatten.last&.strip
        scan || ''
      end

      def validation?(line)
        unless comment?(line)
          scan = line.scan(validation_regex).flatten.last&.strip
          hash[:validations] << scan if scan
        end
        scan
      end

      def association?(line)
        unless comment?(line)
          scan = line.scan(association_regex).flatten.last&.strip
          hash[:associations] << scan if scan
        end
        scan
      end

      def constant?(line)
        unless comment?(line)
          scan = line.scan(constant_regex).flatten.last&.strip
          hash[:constants] << scan if scan
        end
        scan
      end
    end
  end
end

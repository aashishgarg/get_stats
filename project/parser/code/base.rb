module Stats
  module Project
    module Parser
      module Code
        class Base
          def comment?(line)
            !line.scan(comment_regex).empty?
          end

          def class?(line)
            scan = line.scan(class_regex).flatten.last&.strip
            if !comment?(line) && scan
              classes << scan
              hash['classes'][scan] = { 'superclass' => superclass(line), 'methods' => {} }
            end
            scan
          end

          def method?(line)
            scan = line.scan(method_regex).last&.strip
            if !comment?(line) && scan
              methods << scan
              hash['classes'][classes.last]['methods'][scan] = { 'blocks' => [] }
            end
            scan
          end

          def block?(line)
            scan = line.scan(block_regex).last&.strip
            if !comment?(line) && scan
              blocks << scan
              hash['classes'][classes.last]['methods'][methods.last]['blocks'] << scan
            end
            scan
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
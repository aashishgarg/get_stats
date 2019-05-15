module Stats
  module Project
    module Parser
      module Regex
        def superclass_regex
          /(?<=<)\s*(\w+)/
        end

        def comment_regex
          /^#/
        end

        def class_regex
          # /\s*(?<=class)\s+(\w+)\s*/
          /\s*(?<=class)\s+\S+/
        end

        def method_regex
          /(?<=def)\s*\S+/
        end

        def block_regex
          /\S+\s+do\s+\|\S+$/
        end

        def class_end_regex
          /^\s*end\s*$/
        end

        def method_end_regex
          /^\s*end\s*$/
        end

        def block_end_regex
          /^\s*end\s*$/
        end
      end
    end
  end
end
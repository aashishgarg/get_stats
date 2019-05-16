module Stats
  module Parser
    module Regex
      def superclass_regex
        /(?<=<)\s*(\S+)/
      end

      def comment_regex
        /^#\S*/
      end

      def module_regex
        /\s*(?<=module)\s+\S+/
      end

      def class_regex
        # /\s*(?<=class)\s+(\w+)\s*/
        /\s*(?<=class)\s+\S+/
      end

      def method_regex
        /(?<=def)\s+\S+/
      end

      def block_regex
        /^.*?\s+do\s+\|\S+$/
      end

      def end_regex
        /^\s*end\s*$/
      end

      def all_blocks_regex
        /^\s*(?:if|begin|case|for|unless|while)[\s+]/
      end

      def public_regex
        /^\s*public\s*$/
      end

      def private_regex
        /^\s*private\s*$/
      end

      def protected_regex
        /^\s*protected\s*$/
      end
    end
  end
end
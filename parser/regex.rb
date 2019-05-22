module Stats
  module Parser
    module Regex
      def superclass_regex
        /(?<=<)\s*(\S+)/
      end

      def comment_regex
        /^\s*#(\s|\S)*/
      end

      def module_regex
        /\s*(?<=module)\s+\S+/
      end

      def class_regex
        # /\s*(?<=class)\s+(\w+)\s*/
        /\s*(?<=class)\s+\S+/
      end

      def method_regex
        /(?<=def)\s+(?:\S|\s)+/
      end

      def block_regex
        /^.*?\s+do\s+\|\S+$/
      end

      def all_blocks_regex
        /^\s*(?:if|begin|case|for|unless|while)[\s+]/
      end

      def end_regex
        /^\s*end\s*$/
      end

      def method_scope_regex
        /^\s*public|private|protected\s*$/
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

      def constant_regex
        /^\s*[A-Z].*\s*=\s*\S+/
      end

      # === Rails MODEL specific Regex ================= #
      def validation_regex
        /\s*validates(?:\s+|_\w+\s+)(?:\S|\s)+/
      end

      def association_regex
        /^\s*(?:has_many_attached|has_many|has_one_attached|has_one|belongs_to|has_and_belongs_to_many|accepts_nested_attributes_for)(?:\s|\S)+/
      end

      def association_name_regex
        /(?<=has_many_attached|has_many|has_one_attached|has_one|belongs_to|has_and_belongs_to_many|accepts_nested_attributes_for)\s+\S+/
      end

      def association_type_regex
        /^\s*(?:has_many_attached|has_many|has_one_attached|has_one|belongs_to|has_and_belongs_to_many|accepts_nested_attributes_for)\s*/
      end

      # Ex - asso.method.next_method
      #      asso.method[]
      #      asso.method
      def method_usage_regex(method)
        /\.#{method}(?:\s*|\[|\.)/
      end
    end
  end
end
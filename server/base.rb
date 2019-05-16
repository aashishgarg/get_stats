module Stats
  module Server
    class Base
      # --- Attribute Accessors --- #
      attr_accessor :result

      def file_name(file)
        File.basename(file, '.rb')
      end
    end
  end
end
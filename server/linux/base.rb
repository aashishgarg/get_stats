module Stats
  module Server
    module Linux
      class Base
        # --- Attribute Accessors --- #
        attr_accessor :result

        def file_name(file)
          File.basename(file, '.rb')
        end
      end
    end
  end
end
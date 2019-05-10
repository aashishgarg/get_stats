module Stats
  module Server
    module Linux
      class Sanitizer
        def repository_path(location, pid)
          location.delete(pid).delete("\n").delete(' :')
        end

        def processes(string)
          string.split("\n").collect {|pair| pair.split(' ')}
        end

        def perform(string)
          string.delete("\n")
        end
      end
    end
  end
end
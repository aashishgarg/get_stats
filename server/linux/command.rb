require_relative './base'

module Stats
  module Server
    module Linux
      class Command < Base
        attr_accessor :ask_pass_path

        def initialize(ask_pass_path)
          @ask_pass_path = ask_pass_path
        end

        def os_release
          `lsb_release -ds ` + `/bin/uname -r`.chomp
        end

        # Tested for [puma, thin, unicorn, webrick, Passenger]
        def server_pids
          `lsof -wni | grep ruby | grep IPv4 | awk '{print $2}'`
        end

        def redis_pids
          `export SUDO_ASKPASS=#{ask_pass_path};sudo -A netstat -nlp | grep redis | grep 'tcp' | awk '{print $4 }'`
        end

        def start_time(pid)
          `ps -eo pid,lstart | grep #{pid} | awk '{print $4"-"$3"-"$6" Time - "$5"("$2")"}'`.delete("\n")
        end

        def repository(pid)
          `pwdx #{pid}`
        end

        def port(pid)
          `export SUDO_ASKPASS=#{ask_pass_path};sudo -A netstat -tulnp | grep #{pid} | awk '{print $4}'`
        end

        def p_name(pid)
          `export SUDO_ASKPASS=#{ask_pass_path};sudo -A netstat -tulnp | grep #{pid} `
        end
      end
    end
  end
end
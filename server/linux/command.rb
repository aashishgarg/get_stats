require_relative './base'

module Stats
  module Server
    module Linux
      class Command < Base
        def release
          `lsb_release -ds ` + `/bin/uname -r`.chomp
        end

        def app_servers_pids
          `lsof -wni | grep ruby | grep IPv4 | awk '{print $2,$9}'`
        end

        def redis_server_pids
          `sudo -A netstat -nlp | grep redis | grep 'tcp' | awk '{print $7,$4 }'`
        end

        # Tested for [Passenger, puma, thin, webrick]
        def active_processes
          # `export SUDO_ASKPASS=#{ask_pass_path};sudo -A netstat -nlp | grep #{app_server} | grep 'tcp' | awk '{print $7,$4 }'`
          `lsof -wni | grep ruby | awk '{print $2,$9}'`
        end

        def start_time(pid)
          `ps -eo pid,lstart | grep #{pid} | awk '{print $4"-"$3"-"$6" Time - "$5"("$2")"}'`.delete("\n")
        end

        def repository(pid)
          `pwdx #{pid}`
          # sanitized_path(`pwdx #{pid}`, pid)
        end
      end
    end
  end
end
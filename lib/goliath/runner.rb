# encoding: utf-8
module Goliath
  
  class Runner

    def run(process_name = nil)

      unless Goliath.test?
        $LOADED_FEATURES.unshift(File.basename($0))
        Dir.chdir(File.expand_path(File.dirname($0)))
      end

      if @daemonize
        Process.fork do
          Process.setsid
          exit if fork

          @pid_file ||= './goliath.pid'
          @log_file ||= File.expand_path('goliath.log')
          store_pid(Process.pid)

          $0 = process_name if process_name

          Dir.chdir '/'
          File.umask(0000)

          stdout_log_file = "#{File.dirname(@log_file)}/#{File.basename(@log_file)}_stdout.log"

          STDIN.reopen("/dev/null")
          STDOUT.reopen(stdout_log_file, "a")
          STDERR.reopen(STDOUT)

          run_server
        end
      else
        run_server
      end

    end # run

    private

    def run_server

      log = setup_logger

      server = Goliath::Server.new(@address, @port)
      server.logger = log
      server.app = @app
      server.api = @api
      server.plugins = @plugins || []
      server.options = @server_options

      server.start do

        log.info("Starting server on #{server.address}:#{server.port} in #{::Goliath.env} mode. Watch out for stones.")

      end

    end # run_server

  end # Runner

end # Goliath
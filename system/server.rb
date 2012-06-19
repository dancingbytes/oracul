# encoding: utf-8
module Oracul

  class Server < ::Goliath::Runner

    def self.start(env)

      runner = new([], nil)

      ::Goliath.env = env

      runner.log_file = ::Oracul.log_file
      runner.pid_file = ::Oracul.pid_file
      runner.api      = ::Application.new
      runner.app      = ::Goliath::Rack::Builder.build(::Application, runner.api)

      runner.run

    end # self.start

    def run

      unless ::Goliath.env?(:test)
        $LOADED_FEATURES.unshift(::File.basename($0))
        Dir.chdir(::File.expand_path(::File.dirname($0)))
      end

      ::Process.fork do

        ::Process.setsid
        exit if fork

        store_pid(::Process.pid)

        $0 = ::Oracul::APP_NAME

        ::Dir.chdir '/'
        ::File.umask(0000)

        ::STDIN.reopen("/dev/null")
        ::STDOUT.reopen(@log_file || "/dev/null", "a")
        ::STDERR.reopen(STDOUT)
        ::STDOUT.sync = true
        ::STDERR.sync = true

        run_server

      end # fork

    end # run

    private

    def run_server

      log = setup_logger

      server = ::Oracul::Goliath::Server.new
      server.logger = log
      server.app = @app
      server.api = @api
      server.plugins = @plugins || []
      server.options = @server_options

      server.start do

        log.info("Starting server on #{server.address}:#{server.port} in #{::Goliath.env} mode. Watch out for stones.")

      end

    end # run_server

  end # Server

end # Oracul
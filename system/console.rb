# encoding: utf-8
require 'irb'

module Oracul

  class Console < ::Goliath::Runner

    def self.start(env)

      runner = new([], nil)

      ::Goliath.env = env

      runner.api = ::Application.new
      runner.app = ::Goliath::Rack::Builder.build(::Application, runner.api)

      runner.run

    end # self.start

    def self.irb_console

      $0 = ::Oracul::APP_NAME

      ::IRB.setup(nil)

      ::IRB.conf[:PROMPT][:DEFAULT] = {
        :PROMPT_I => "#{$0} :%03n:%i> ",
        :PROMPT_N => "#{$0} :%03n:%i> ",
        :PROMPT_S => "#{$0} :%03n:%i%l ",
        :PROMPT_C => "#{$0} :%03n:%i* ",
        :RETURN => "=> %s\n"
      }

      ::IRB.conf[:PROMPT_MODE] = :DEFAULT

      irb = ::IRB::Irb.new

      ::IRB.conf[:IRB_RC].call(irb.context) if ::IRB.conf[:IRB_RC]
      ::IRB.conf[:MAIN_CONTEXT] = irb.context

      trap("SIGINT") do
        irb.signal_handle
      end

      begin
        catch(:IRB_EXIT) do
          irb.eval_input
        end
      ensure
        ::IRB.irb_at_exit
      end

    end # self.irb_console

    def run

      unless ::Goliath.env?(:test)
        $LOADED_FEATURES.unshift(::File.basename($0))
        ::Dir.chdir(::File.expand_path(::File.dirname($0)))
      end

      run_server

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

        self.class.irb_console
        exit

      end

    end # run_server

  end # Console

end # Oracul
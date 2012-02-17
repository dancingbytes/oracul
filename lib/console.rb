# encoding: utf-8
require 'irb'
require 'irb/completion'

module Oracul
  
  class Console < ::Goliath::Runner

    def self.start(env)

      runner = new([], nil)
        
      ::Goliath.env = env
        
      runner.api = ::Oracul::Routes.new
      runner.app = ::Goliath::Rack::Builder.build(::Oracul::Routes, runner.api)
        
      runner.run

    end # self.start

    def run
      
      unless ::Goliath.test?
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
        
        ::IRB.start        
        exit

      end
     
    end # run_server

  end # Console
  
end # Oracul
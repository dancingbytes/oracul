# encoding: utf-8
require 'rubygems'
require 'bundler'

require 'goliath/api'
require 'goliath/runner'

require 'em-mongo'

Dir[
  './lib/*.rb', 
  './app/**/*.rb'
].each {|f| require f }

require File.expand_path('../routes', __FILE__)

module Oracul

  APP_NAME = "Oracul"

  class << self

    def root
      @root ||= ::File.join(::File.dirname(__FILE__), "../")
    end # root

    def log_file
      @log_file ||= get_or_create(root, "logs", "#{::Goliath.env}.log")
    end # log_file

    def pid_file
      @pid_file ||= get_or_create(root, "tmp", "pids", "app.pid")
    end # pid_file

    def status
      env["status"] || {}
    end # status

    def env
      Thread.current[::Goliath::Constants::GOLIATH_ENV]
    end # env

    def options
      Oracul::Goliath::Server.options || {}
    end # options
    
    def config
      Oracul::Goliath::Server.config || {}
    end # config

    def plugins
      Oracul::Goliath::Server.plugins || {}
    end # plugins    

    private

    def get_or_create(*args)

      last = args.pop

      if last
        dir = File.join(*args)
        ::FileUtils.mkdir_p(dir, :mode => 0755) unless ::FileTest.directory?(dir)
        args << last
      end
      ::File.join(*args)

    end # get_or_create

  end # class << self

end # Oracul
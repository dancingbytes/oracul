# encoding: utf-8
require 'rubygems'
require 'bundler'

require 'goliath/api'
require 'goliath/runner'

Dir[
  './lib/*.rb', 
  './app/**/*.rb'
].each {|f| require f }

require File.expand_path('../routes', __FILE__)

module Oracul

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
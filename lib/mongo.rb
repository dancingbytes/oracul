# encoding: utf-8
require 'em-mongo'
require 'em-synchrony/em-mongo'

module Mongo

  extend self

  def conn
    @conn ||= ::Oracul.config['mongo']
  end # conn

end # Mongo
# encoding: utf-8
require 'grape'

class Oracul::API < Grape::API

  format :json

  Dir[ './app/resources/*.rb' ].each { |f|
    instance_eval(::IO.read(f), f)
  }

end # Oracul::API

class Application < Goliath::API

  def response(env)
    Oracul::API.call(env)
  end # response

end # Application
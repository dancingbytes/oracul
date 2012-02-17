# encoding: utf-8
class TestAction < Goliath::API

  def response(env)
    [200, {}, {:response => Mongo.areas}]
  end # response

end # TestAction
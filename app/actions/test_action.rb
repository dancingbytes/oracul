# encoding: utf-8
class TestAction < Goliath::API

  def response(env)
    [200, {}, {:response => env.config}]
  end # response

end # TestAction
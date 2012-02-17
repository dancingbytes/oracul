# encoding: utf-8
class Mongo

  class << self

    def db
      @conn ||= ::Oracul.config['mongo']
    end # db

    def areas
      @areas ||= db.collection('areas')
    end # areas

  end # class << self

end # Mongo
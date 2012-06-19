# encoding: utf-8
module Area

  extend self

  def search_city(name, page = 1)

    return [] if name.length < 2

    page = 1  if page < 1
    per  = 25
    name = name.sub(/\A[а-я]+\.(\s)?/i, "").clean_whitespaces

    conn.find({
      :keywords => name, :place_type => 1
    }, {
      :limit => page*per, :skip => (page-1)*per
    })

  end # search_city

  def search_street(city_name, postcode, name = '', page = 1)

    page = 1  if page < 1
    per  = 25
    name = name.sub(/\A[а-я]+\.(\s)?/i, "").clean_whitespaces

    params = {
      :place_type => 2,
      :city_name  => city_name,
      :city_postcodes => { "$in" => postcode }
    }

    params[:keywords] = name if name.length > 0

    conn.find(params, {
      :limit => page*per, :skip => (page-1)*per
    })

  end # search_city

  private

  def conn
    @conn ||= ::Mongo.conn.collection('areas')
  end # conn

end # Area
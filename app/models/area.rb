# encoding: utf-8
module Area

  extend self

  FIELDS = {
    :version        => 1,
    :name           => 1,
    :abbr           => 1,
    :abbr_full      => 1,
    :abbr_code      => 1,
    :region_code    => 1,
    :district_code  => 1,
    :area_code      => 1,
    :village_code   => 1,
    :status_village => 1,
    :street_code    => 1,
    :house_code     => 1,
    :postcodes      => 1,
    :place_type     => 1,
    :locality       => 1,
    :region         => 1,
    :district       => 1,
    :area           => 1
  }

  PER_PAGE = 25

  def search_city(name, page = 1, revision = nil)

    return [] if name.length < 2

    page = 1  if page < 1
    name = name.sub(/\A[а-я]+\.(\s)?/i, "").downcase.clean_whitespaces

    conn.find({
      :keywords   => name,
      :place_type => 1,
      :outdated   => false,
      :revision   => (revision.blank? ? last_revision : revision).to_i
    }, {
      :limit  => page*PER_PAGE, :skip => (page-1)*PER_PAGE,
      :fields => FIELDS
    })

  end # search_city

  def search_street(city_name, postcode, name = '', page = 1, revision = nil)

    page = 1  if page < 1
    name = name.sub(/\A[а-я]+\.(\s)?/i, "").downcase.clean_whitespaces

    params = {
      :place_type => 2,
      :city_name  => city_name,
      :city_postcodes => { "$in" => postcode },
      :outdated   => false,
      :revision   => (revision.blank? ? last_revision : revision).to_i
    }

    params[:keywords] = name if name.length > 0

    conn.find(params, {
      :limit  => page*PER_PAGE, :skip => (page-1)*PER_PAGE,
      :fields => FIELDS
    })

  end # search_city

  private

  def last_revision

    return @last_revision if @last_revision

    result = conn.find({}, {
      :limit  => 1,
      :fields => { :revision => 1 },
      :order  => [ ['revision', 'descending'] ]
    }).first

    @last_revision = result ? result['revision'] : 1

  end # last_version

  def conn
    @conn ||= ::Mongo.conn.collection('areas')
  end # conn

end # Area
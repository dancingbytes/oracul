# encoding: utf-8
version 'v1', :using => :path do

  resource 'street' do

    get "/search/:city_name/:postcode(/:name(/:page))", { :optional_params => [ "revision" ] } do

      ::Area.search_street(
        params['city_name'],
        params['postcode'],
        params['name'] || '',
        params['page'] || 1,
        params['revision']
      )

    end

  end # city

end # v1
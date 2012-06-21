# encoding: utf-8
version 'v1', :using => :path do

  resource 'city' do

    get "/search/:name(/:page)", { :optional_params => [ "revision" ] } do

      ::Area.search_city(
        params['name'],
        params['page'] || 1,
        params['revision']
      )

    end

  end # city

end # v1
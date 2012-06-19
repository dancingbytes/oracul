# encoding: utf-8
version 'v1', :using => :path do

  resource 'city' do

    get "/search/:name(/:page)" do
      ::Area.search_city(params['name'], params['page'] || 1)
    end

  end # city

end # v1
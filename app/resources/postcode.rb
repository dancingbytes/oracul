# encoding: utf-8
version 'v1', :using => :path do

  resource 'postcode' do

    get "/list/:city_name/:postcode" do
      ::Area.postcodes(params['city_name'], params['postcode'])
    end

  end # city

end # v1
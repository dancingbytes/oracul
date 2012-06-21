# encoding: utf-8
module OraculUpdater

  #
  # Информацию получаем с сайта: http://ipgeobase.ru/
  # Актуальные базы лежат тут: http://ipgeobase.ru/cgi-bin/Archive.cgi
  #

  class GeoIp

    REGION_MAP_RELATION = {

      "Республика Чувашия"        => "Чувашская Республика",
      "Республика Карачаево-Черкессия" => "Карачаево-Черкесская Республика",
      "Республика Удмуртия"       => "Удмуртская Республика",
      "Республика Саха (Якутия)"  => 'Республика Саха \(Якутия\)',
      "Республика Тыва (Тува)"    => "Республика Тыва",
      "Республика Кабардино-Балкария" => "Кабардино-Балкарская Республика",
      "Республика Чечня" => "Чеченская Республика"

    }.freeze

    def initialize(revision = 1)

      @revision = revision

      load_cities
      load_cidr_optim

    end # new

    def clear_all

      puts "*** Delete all"

      # ::OraculUpdater::Area.where(:revision => @revision).with(safe: true).update_all({
      #   :location => []
      # })

      ::OraculUpdater::Ip.where(:revision => @revision).with(safe: true).delete_all

      puts " *** Done."
      puts
      self

    end # clear_all

    def save_geo_and_ips

      puts "Save geoip datas to Area..."

      total   = @cities.keys.length
      counter = 0
      error   = 0

      request = ::OraculUpdater::Area.by_revision(@revision).actual

      @cities.each { |key, value|

        notfound = ""
        counter += 1

        city = request.find_by_name(value[:name]).city_only
        city = request.find_by_name(value[:name].gsub("-", " ")).city_only  if city.count == 0
        city = city.where(:region => /#{value[:region]}/i)                  if city.count > 1

        if city.count == 0

          city = request.find_by_name(value[:name])
          city = request.find_by_name(value[:name].gsub("-", " "))  if city.count == 0
          city = city.where(:region => /#{value[:region]}/i)        if city.count > 1

        end

        if city.count == 0

          city = request.find_by_name(value[:name].gsub(" ", "-"))
          city = city.where(:region => /#{value[:region]}/i) if city.count > 1

        end

        if (city = city.first)

          ::OraculUpdater::Area.with(safe: true).
            where(:_id => city.id).
            update_all({
              :location => value[:coordinates]
            })

          value[:ips].each do |el|

            ::OraculUpdater::Ip.create({
              :revision => @revision,
              :lft      => el[0],
              :rgt      => el[1],
              :area_id  => city.id
            })

          end

        else

          error += 1
          notfound = " [Not found #{value[:name]} (#{value[:region]}) -> #{value[:district]}]"
          puts "#{notfound}"

        end

        progress = sprintf("%0.4f", (counter.to_f / total)*100)
        puts " Save geoip datas [#{counter} / #{total} / #{error}] => #{progress} % #{notfound}"

      }
      puts "Done."
      self

    end # save_geo_and_ips

    private

    def load_cities

      @cities = {}
      load_file("cities") do |num, result|

        cityid        = result[0].to_i
        name          = result[1].sub("п. ", "").sub("пос. ", "")
        region        = ["Москва", "Санкт-Петербург"].include?(name) ? "" : result[2]
        district      = result[3]
        coordinates   = [result[4].to_f, result[5].to_f]

        @cities[cityid] = {
          :name         => name,
          :region       => REGION_MAP_RELATION[region] || region,
          :district     => district,
          :coordinates  => coordinates,
          :ips          => []
        }

      end # load_file
      self

    end # load_cities

    def load_cidr_optim

      load_file("cidr_optim") do |num, result|

        start   = result[0].to_i
        stop    = result[1].to_i
        inetnum = result[2]
        country = result[3]
        cityid  = result[4].to_i

        if (country =~ /RU/i) && (city = @cities[cityid])
          city[:ips] << { :lft => start, :rgt => stop }
        else
          @cities.delete(cityid)
        end

      end # load_file
      self

    end # load_cidr_optim

    def load_file(name, ext = "txt")

      file_name = "#{name}.#{ext}"
      file = File.join(::File.dirname(__FILE__), "../", "tmp", file_name)
      unless File.exists?(file)
        puts "File #{file_name} not found. Skip."
      else

        puts "Load datas from #{file_name}..."

        begin
          fl = File.new(file)
          fl.each { |line|
            data = line.encode("UTF-8", "WINDOWS-1251").split(/\t/)
            yield(fl.lineno, data)
          }
        ensure
          fl.close
        end

        puts "Done."
        puts

      end

    end # load_file

  end # GeoIp

end # OraculUpdater
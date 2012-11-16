# encoding: utf-8
module OraculUpdater

  #
  # Информацию получаем с сайта: http://www.gnivc.ru
  # Актуальные базы лежат тут: http://www.gnivc.ru/inf_provision/classifiers_reference/kladr/
  #

  class Kladr

    def initialize(revision = 1)
      @revision = revision
    end # new

    def clear_all

      puts "*** Delete all"
      ::OraculUpdater::Area.where(:revision => @revision).with(safe: true).delete_all
      puts " *** Done."
      puts
      self

    end # clear_all

    def convert_areas

      # Areas
      datas = db("KLADR")
      return self unless datas

      counter, total = 0, datas.record_count
      success, error = 0, 0

      datas.each do |record|

        counter += 1

        next if record.nil?

        attrs = record.attributes
        code  = attrs["CODE"]

        region_code   = code[0, 2].to_i
        district_code = code[2, 3].to_i
        area_code     = code[5, 3].to_i
        village_code  = code[8, 3].to_i
        postcode      = attrs["INDEX"].try(:to_i) || 0

        locality = if district_code == 0 && area_code == 0 && village_code == 0
          1
        elsif district_code != 0 && area_code == 0 && village_code == 0
          2
        elsif district_code != 0 && area_code != 0 && village_code == 0
          3
        else
          4
        end

        area = ::OraculUpdater::Area.new({

          :revision => @revision,

          :name => attrs["NAME"].encode("UTF-8", "CP866"),
          :abbr => attrs["SOCR"].encode("UTF-8", "CP866"),

          :region_code          => region_code,
          :district_code        => district_code,
          :area_code            => area_code,
          :village_code         => village_code,

          :status_village       => attrs["STATUS"].try(:to_i),
          :locality             => locality

        })

        area.outdated  = (code[11, 2].to_i != 0)
        area.postcodes = [postcode] if postcode > 0

        if result = area.save
          success += 1
        else
          error += 1
        end

        progress = sprintf("%0.4f", (counter.to_f / total)*100)
        puts " Insert areas (kladr) [#{counter} / #{total}] => #{progress} % [#{(result ? 'success' : 'failure')}]"

        unless result
          puts " Error: #{area.errors.inspect}"
          puts " Record: #{record.attributes}"
          puts
        end

      end # each

      # Республика Чувашия
      ::OraculUpdater::Area.with(safe: true).where({
        :revision => @revision,
        :abbr     => "Чувашия"
      }).update_all({

        :abbr => "Респ",
        :name => "Чувашская"

      })

      puts
      self

    end # convert_areas

    def convert_streets

      # Streets
      datas = db("STREET")
      return self unless datas

      counter, total = 0, datas.record_count
      success, error = 0, 0

      datas.each do |record|

        counter += 1

        next if record.nil?

        attrs = record.attributes
        code  = attrs["CODE"]

        region_code   = code[0, 2].to_i
        district_code = code[2, 3].to_i
        area_code     = code[5, 3].to_i
        village_code  = code[8, 3].to_i
        street_code   = code[11, 4].to_i
        postcode      = attrs["INDEX"].try(:to_i) || 0


        area = ::OraculUpdater::Area.new({

          :revision => @revision,

          :name => attrs["NAME"].encode("UTF-8", "CP866"),
          :abbr => attrs["SOCR"].encode("UTF-8", "CP866"),

          :region_code        => region_code,
          :district_code      => district_code,
          :area_code          => area_code,
          :village_code       => village_code,
          :street_code        => street_code,
          :locality           => 5

        })

        area.outdated  = (code[15, 2].to_i != 0)
        area.postcodes = [postcode] if postcode > 0

        if result = area.save
          success += 1
        else
          error += 1
        end

        progress = sprintf("%0.4f", (counter.to_f / total)*100)
        puts " Insert streets [#{counter} / #{total}] => #{progress} % [#{(result ? 'success' : 'failure')}]"

        unless result
          puts " Error: #{area.errors.inspect}"
          puts " Record: #{record.attributes}"
          puts
        end

      end # each

      puts
      self

    end # convert_streets

    def convert_houses

      # Houses
      datas = db("DOMA")
      return self unless datas

      counter, total = 0, datas.record_count
      success, error = 0, 0

      datas.each do |record|

        counter += 1

        next if record.nil?

        attrs = record.attributes
        code  = attrs["CODE"]

        region_code   = code[0, 2].to_i
        district_code = code[2, 3].to_i
        area_code     = code[5, 3].to_i
        village_code  = code[8, 3].to_i
        street_code   = code[11, 4].to_i
        house_code    = code[15, 4].to_i

        postcode      = attrs["INDEX"].try(:to_i) || 0

        area = ::OraculUpdater::Area.new({

          :revision => @revision,

          :name => attrs["NAME"].encode("UTF-8", "CP866"),
          :abbr => attrs["SOCR"].encode("UTF-8", "CP866"),

          :region_code        => region_code,
          :district_code      => district_code,
          :area_code          => area_code,
          :village_code       => village_code,
          :street_code        => street_code,
          :house_code         => house_code,

          :locality           => 6

        })

        area.postcodes  = [postcode] if postcode > 0
        area.place_type = 3

        if result = area.save
          success += 1
        else
          error += 1
        end

        progress = sprintf("%0.4f", (counter.to_f / total)*100)
        puts " Insert houses [#{counter} / #{total}] => #{progress} % [#{(result ? 'success' : 'failure')}]"

        unless result
          puts " Error: #{area.errors.inspect}"
          puts " Record: #{record.attributes}"
          puts
        end

      end # each

      puts
      self

    end # convert_houses

    def set_abbreviation

      # Update areas abbreviation
      datas = db("SOCRBASE")
      return self unless datas

      counter, total = 0, datas.record_count

      datas.each do |record|

        counter += 1

        next if record.nil?

        attrs = record.attributes

        ::OraculUpdater::Area.with(safe: true).where({

          :revision => @revision,

          :abbr     => attrs["SCNAME"].encode("UTF-8", "CP866"),
          :locality => attrs["LEVEL"].try(:to_i)

        }).update_all({

          :abbr_full => attrs["SOCRNAME"].encode("UTF-8", "CP866"),
          :abbr_code => attrs["KOD_T_ST"].try(:to_i)

        })

        result = "[#{attrs['LEVEL']}] #{attrs['KOD_T_ST']} -> (#{attrs['SOCRNAME'].encode('UTF-8', 'CP866')}) #{attrs['SCNAME'].encode('UTF-8', 'CP866')}"

        progress = sprintf("%0.4f", (counter.to_f / total)*100)
        puts " Update abbreviation [#{counter} / #{total}] => #{progress} % | #{result}"

      end # each

      puts
      self

    end # set_abbreviation


    def set_city_type

      puts "*** Set city type"

      arr = [

        # Данные на март 2012 года.
        103, # Город

        301, # Город
        302, # Послелок городского типа
        303, # Рабочий поселок
        304, # Курортный поселок
        305, # Дачный поселок
        306, # Сельсовет

        314, # Сельское поселение
        317, # Поселок

        401, # Аал
        402, # Аул
        404, # Выселки
        405, # Город
        406, # Деревня
        407, # Дачный поселок
        416, # Курортный поселок
        417, # Местечко
        419, # Населенный пункт
        421, # Поселок
        423, # Поселок при станции
        424, # Поселок городского типа
        425, # Починок

        429, # Рабочий поселок
        430, # Село
        431, # Слобода
        433, # Станица
        434, # Улус
        435, # Хутор
        436, # Городок

        440, # Арбан

        532, # Аал
        533, # Аул
        534, # Выселки
        535, # Городок
        536, # Деревня
        544, # Местечко
        546, # Населенный пункт
        548, # Поселок
        551, # Поселок при станции
        552, # Полустанок
        555, # Село
        556, # Слобода
        558  # Хутор

      ]

      counter, total = 0, arr.length

      arr.each do |code|

        ::OraculUpdater::Area.with(safe: true).where({
          :revision   => @revision,
          :abbr_code  => code
        }).update_all({
          :place_type => 1
        })

        counter += 1

        progress = sprintf("%0.2f", (counter.to_f / total)*100)
        puts " Set city type [#{counter} / #{total}] => #{progress} % | #{code}"

      end # each

      puts " *** Done."
      puts
      self

    end # set_city_type


    def set_street_type

      puts "*** Set street type"

      arr = [

        # Данные на март 2012 года.
        439, # Квартал
        447, # Жилая зона

        501, # Аллея
        502, # Бульвар
        503, # Въезд
        504, # Дорога
        506, # Заезд
        507, # Квартал
        509, # Кольцо
        510, # Линия
        511, # Набережная
        513, # Парк
        514, # Переулок
        515, # Переезд
        516, # Площадь
        518, # Проезд
        519, # Проспект
        522, # Проулок
        524, # Сквер
        # 525, # Строение
        527, # Тракт
        528, # Тупик
        529, # Улица
        531, # Шоссе
        545, # Микрорайон
        554, # Разъезд
        561, # Спуск
        568  # Вал

      ]

      counter, total = 0, arr.length

      arr.each do |code|

        ::OraculUpdater::Area.with(safe: true).where({
          :revision   => @revision,
          :abbr_code  => code
        }).update_all({
          :place_type => 2
        })

        counter += 1

        progress = sprintf("%0.2f", (counter.to_f / total)*100)
        puts " Set street type [#{counter} / #{total}] => #{progress} % | #{code}"

      end # each

      puts " *** Done."
      puts
      self

    end # set_street_type


    def refresh_area_locations

      puts "*** Refresh area locations"

      total   = ::OraculUpdater::Area.by_revision(@revision).city_only.actual.count
      counter = 0
      step    = 300

      ::OraculUpdater::Area.by_revision(@revision).city_only.actual.long_query(step) do |area|

        city_region, city_district, city_area = nil, nil, nil

        city_region = ::OraculUpdater::Area.
          by_revision(@revision).
          by_region(area.region_code).
          by_district(0).
          by_area(0).
          by_village(0).
          by_street(0).
          actual.
          first

        unless city_region.nil?

          if city_region.abbr_code == 106
            region_str = ::OraculUpdater::Area::REPUBLICS[area.region_code]
          elsif city_region.id != area.id
            region_str = "#{city_region.name} #{city_region.abbr_full.downcase}"
          end

        end # unless

        case area.status_village

          when 1 then

            city_district = nil

            city_area = ::OraculUpdater::Area.
              by_revision(@revision).
              by_region(area.region_code).
              by_district(area.district_code).
              by_area(area.area_code).
              by_village(0).
              by_street(0).
              actual.
              first if area.area_code > 0

            city_area = nil if city_area && city_area.id == area.id

          when 2,3 then

            city_district = nil
            city_area     = nil

          else

            city_district = ::OraculUpdater::Area.
              by_revision(@revision).
              by_region(area.region_code).
              by_district(area.district_code).
              by_area(0).
              by_village(0).
              by_street(0).
              actual.
              first if area.district_code > 0

            city_area = ::OraculUpdater::Area.
              by_revision(@revision).
              by_region(area.region_code).
              by_district(area.district_code).
              by_area(area.area_code).
              by_village(0).
              by_street(0).
              actual.
              first if area.area_code > 0

            city_area = nil if city_area && city_area.id == area.id

        end

        # Индексы улиц и домов
        req = ::OraculUpdater::Area.
          by_revision(@revision).
          by_region(area.region_code).
          by_district(area.district_code).
          by_area(area.area_code).
          by_village(area.village_code)

        postcodes = [area.postcodes, req.distinct(:postcodes)].flatten.compact.uniq

        # Для населенных пунктов сохраняем информацию о области/регионе/районе/почтовых индексах
        ::OraculUpdater::Area.
          with(safe: true).
          where(:_id => area.id).
          update_all({

            :region     => region_str,
            :district   => (city_district.nil? ? nil : "#{city_district.name} #{city_district.abbr_full.downcase}"),
            :area       => (city_area.nil? ? nil : city_area.name),
            :postcodes  => postcodes#,
#            :city_name  => area.name,
#            :city_postcodes => postcodes

          })

=begin
        # Для улиц и домов данного населенного пункта сохраняем информацию
        # о названии населенного пункта и его почтовых индексов
        req.update_all({
          :city_name      => area.name,
          :city_postcodes => postcodes
        })
=end

        # Для населенных пунктов в keywords добавим данные о районе (для более точного поиска)
        area.add_keywords(area.district)

        counter += 1
        progress = sprintf("%0.4f", (counter.to_f / total)*100)
        puts " Refresh area locations [#{counter} / #{total}] => #{progress} % | #{area.name}"

      end # long_query

      puts
      self

    end # refresh_area_locations

    private

    def db(name, ext = "DBF")

      file = File.join(::File.dirname(__FILE__), "../", "tmp", "#{name}.#{ext}")
      unless File.exists?(file)
        puts "File #{name}.#{ext} not found. Skip. #{file}"
        false
      else
        DBF::Table.new(file)
      end

    end # db

  end # Kladr

end # OraculUpdater
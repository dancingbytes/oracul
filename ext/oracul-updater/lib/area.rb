# encoding: utf-8

=begin

    # [abbr_code]
    # Населенные пункты  (данные на март 2012 года).
    #

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

=end

module OraculUpdater

  class Area

    include Mongoid::Document

    store_in collection: "areas"

    REPUBLICS = {

      1  => "Республика Адыгея",
      2  => "Республика Башкортостан",
      3  => "Республика Бурятия",
      4  => "Республика Алтай",
      5  => "Республика Дагестан",
      6  => "Республика Ингушетия",
      7  => "Кабардино-Балкарская Республика",
      8  => "Республика Калмыкия",
      9  => "Карачаево-Черкесская Республика",
      10 => "Республика Карелия",
      11 => "Республика Коми",
      12 => "Республика Марий Эл",
      13 => "Республика Мордовия",
      14 => "Республика Саха (Якутия)",
      15 => "Республика Северная Осетия",
      16 => "Республика Татарстан",
      17 => "Республика Тыва",
      18 => "Удмуртская Республика",
      19 => "Республика Хакасия",
      20 => "Чеченская Республика",
      21 => "Чувашская Республика"

    }.freeze

    # Ревизия (версия)
    field  :revision,             :type => Integer, :default => 0

    # Код обозначения (тип объекта)
    field  :abbr_code,            :type => Integer, :default => 0 # size: 3

    # Код региона РФ
    field  :region_code,          :type => Integer, :default => 0 # size: 2

    # Код района
    field  :district_code,        :type => Integer, :default => 0 # size: 3

    # Код области
    field  :area_code,            :type => Integer, :default => 0 # size: 3

    # Код города (поселения)
    field  :village_code,         :type => Integer, :default => 0 # size: 3

    # Статус населенного пункта
    #
    # 0 - объект не является центром административно-территориального образования;
    # 1 – объект является центром района;
    # 2 – объект является центром (столицей) региона;
    # 3 – объект является одновременно и центром района и центром региона;
    # 4 – центральный район, т.е. район, в котором находится центр региона
    # (только для объектов 2-го уровня).
    #
    field  :status_village,       :type => Integer, :default => 0 # size: 2

    # Код улицы
    field  :street_code,          :type => Integer, :default => 0 # size: 4

    # Код дома
    field  :house_code,           :type => Integer, :default => 0 # size: 4

    # Индексы
    field  :postcodes,            :type => Array,   :default => []

    # Отметка актуальности данных
    field  :outdated,             :type => Boolean, :default => false

    # Тип объекта
    #
    # 0 - Неклассифицировано
    # 1 - Населенный пункт
    # 2 - Улица
    # 3 - Дом
    #
    field  :place_type,           :type => Integer, :default => 0 # size => 1

    # Уровень объекта
    field  :locality,             :type => Integer, :default => 0 # size => 1

    # Название
    field  :name,                 :type => String

    # Поисковые слова
    field  :keywords,             :type => Array

    # Аббревиатура
    field  :abbr,                 :type => String

    # Полное обозначение
    field  :abbr_full,            :type => String

    # Название региона
    field  :region,               :type => String

    # Название района
    field  :district,             :type => String

    # Название области
    field  :area,                 :type => String

=begin
    # Название города/деревни (для улицы/дома)
    # Используется для быстрого поиска
    field  :city_name,            :type => String

    # Почтовые коды города/деревни (для улицы/дома)
    # Используется для быстрого поиска
    field  :city_postcodes,       :type => Array
=end

    # Географические координаты (Latitude (Широта) / Longitude (Долгота))
    field  :location,             :type => Array

    index(

      {
        revision:       1,
        region_code:    1,
        district_code:  1,
        area_code:      1,
        village_code:   1,
        street_code:    1,
        house_code:     1,
        outdated:       1

      }, {
        name:       "area_indx",
        background: true
      }

    )

    index(

      {
        revision:     1,
        keywords:     1,
        place_type:   1
      }, {
        name:       "area_indx_2",
        background: true

      }

    )

    index(

      {
        revision:     1,
        abbr:         1,
        locality:     1
      }, {
        name:       "area_indx_3",
        background: true
      }

    )

    index({ outdated:   1 }, { background: true })
    index({ abbr_code:  1 }, { background: true })
    index({ locality:   1 }, { background: true })
    index({ postcodes:  1 }, { background: true })
    index({ place_type: 1 }, { background: true })
    index({ revision:   1 }, { background: true })
    index({ location:   '2d' }, { background: true })

=begin
    index({

      revision:     1,
      keywords:     1,
      place_type:   1,
      outdated:     1

    }, {
      name: "area_indx_1"
    })

    index({

      revision:     1,
      city_name:    1,
      city_postcodes: 1,
      outdated:     1

    }, {
      name: "area_indx_2"
    })

    index({

      revision:     1,
      abbr:         1,
      locality:     1

    }, {
      name: "area_indx_3"
    })

    index({

      revision:     1,
      place_type:   1,
      outdated:     1

    }, {
      name: "area_indx_4"
    })

    index({

      revision:     1,
      region_code:  1,
      district_code:1,
      area_code:    1,
      village_code: 1,
      street_code:  1,
      outdated:     1

    }, {
      name: "area_indx_5"
    })

    index({

      revision:     1,
      region_code:  1,
      district_code:1,
      area_code:    1,
      village_code: 1

    }, {
      name: "area_indx_6"
    })

    index({

      revision:     1,
      abbr_code:    1

    }, {
      name: "area_indx_7"
    })

    index({

      revision:     1,
      abbr:         1

    }, {
      name: "area_indx_8"
    })

    index({ revision: 1 })
    index({ outdated: 1 })
    index({ location: '2d' })
=end

    before_save :set_keywords

    attr_protected  :keywords,
                    :postcodes,
                    :region,
                    :district,
                    :area,
                    :outdated

    ##
    ## Scopes
    ##

    scope :by_revision, ->(revision) {
      where(:revision => revision.try(:to_i))
    } # by_revision

    scope :by_region, ->(code) {
      where(:region_code => code.try(:to_i))
    } # by_region

    scope :by_district, ->(code) {
      where(:district_code => code.try(:to_i))
    } # by_district

    scope :by_area, ->(code) {
      where(:area_code => code.try(:to_i))
    } # by_area

    scope :by_village, ->(code) {
      where(:village_code => code.try(:to_i))
    } # by_village

    scope :by_street, ->(code) {
      where(:street_code => code.try(:to_i))
    } # by_street

    scope :by_house, ->(code) {
      where(:house_code => code.try(:to_i))
    } # by_house

    scope :actual,  where(:outdated => false)

    scope :city_only,   actual.where(:place_type => 1)

    scope :street_only, actual.where(:place_type => 2)

    scope :house_only,  where(:place_type => 3)

    scope :streets_for, ->(el) {

      by_region(el.region_code).
      by_district(el.district_code).
      by_area(el.area_code).
      by_village(el.village_code).
      actual.
      street_only

    } # streets_for

    scope :houses_for, ->(el) {

      by_region(el.region_code).
      by_district(el.district_code).
      by_area(el.area_code).
      by_village(el.village_code).
      by_house(el.house_code).
      house_only

    } # houses_for

    scope :by_postcode, ->(code) {

      code = code.try(:to_i)
      code = [] if code == 0 || code.nil?
      where(:postcodes => code)

    } # by_postcode

    scope :find_by_name, ->(name, partial = false) {

      name = (name || "").sub(/\A[а-я]+\.(\s)?/i, "").clean_whitespaces.downcase

      if partial
        arr = name.split(/\s/)
        arr.delete_if { |el| el.length < 3 }
      else
        arr = [name]
      end

      asc(:locality).actual.where(:keywords.in => arr)

    } # find_by_name


    ##
    ## Методы класса
    ##

    class << self

      def city_exist?(name = nil, code = nil)
        !get_city_by(name, code).nil?
      end # city_exist?

      def get_city_by(name = nil, code = nil)

        return if name.blank? || code.blank?

        search_city(name)
          .any_of({ :abbr_code => 103 }, { :locality.gt => 1 })
          .by_postcode(code)
          .first

      end # get_city_by

      def search(name)

        (city_name, region, _) = name.split(",")

        if (city_name =~ /\d{6}/).nil?

          request = find_by_name(city_name)
          region  = region.clean_whitespaces || ""

          unless region.blank?
            request = request.any_of({:region => /#{region}/i}, {:district => /#{region}/i})
          end

        else
          request = by_postcode(city_name)
        end

        request

      end # search

      def search_city(name)
        search(name).city_only
      end # search_city

      def search_street(name)
        find_by_name(name, false).street_only
      end # search_street

      def has_city_streets?(city, postcode)
        !!get_city_by(city, postcode).try(:has_streets?)
      end # has_city_streets?

      def has_city_street?(city, postcode, street)
        !!get_city_by(city, postcode).try(:has_street?, street)
      end # has_city_street?

    end # class << self

    ##
    ## Методы экземпляра
    ##

    def search_street(name)
      self.class.streets_for(self).find_by_name(name, false)
    end # search_street

    def postcode
      self.postcodes.first
    end # postcode

    def has_street?(name)
      self.search_street(name).count > 0
    end # has_street?

    def has_streets?
      self.streets.count > 0
    end # has_streets?

    def streets
      self.class.streets_for(self)
    end # streets

    def zone(delimiter = ", ")

      return @zone unless @zone.nil?

      arr = []

      arr << self.region    unless self.region.blank?
      arr << self.district  unless self.district.blank?
      arr << self.area      unless self.area.blank?

      @zone = arr.join(delimiter)

    end # zone

    # Определяем "код" объекта.
    #
    # Начинаем обход кодов домов и поднимаемся до кодов регионов. Как только
    # встречается код отличный от 0 то, используем его в качестве искомого значения.
    #
    def code

      return @code unless @code.nil?

      # Дом
      if (@code = self.house_code) == 0

        # Улица
        if (@code = self.street_code) == 0

          # Деревня/поселок/мелкий городок
          if (@code = self.village_code) == 0

            # Район/крупный город
            if (@code = self.area_code) == 0

              # Область
              if (@code = self.district_code) == 0

                # Регион
                @code = self.region_code

              end #

            end #

          end #

        end #

      end #

      @code

    end # code

    #
    # Определяем "код" объекта (путь до объекта).
    #
    # Начинаем обход кодов домов и поднимаемся до кодов регионов. Последние нули отбрасываем.
    #
    def full_code(delimiter = '/')

      return @full_code unless @full_code.nil?

      arr = []

      # Дом
      arr << self.house_code

      # Улица
      arr << self.street_code

      # Деревня/поселок/мелкий городок
      arr << self.village_code

      # Район/крупный город
      arr << self.area_code

      # Область
      arr << self.district_code

      # Регион
      arr << self.region_code

      # Промежуточный массив
      arr_1 = arr.clone

      # Удаляем первые нули
      arr.each do |el|
        el == 0 ? arr_1.shift : break;
      end # each_index

      # Добавляем начальный 0 (так как у нас есть главнй объект "Россия" с кодом 0)
      arr_1 << 0

      # Разворачиваем массив
      @full_code = arr_1.reverse.join(delimiter)

    end # full_code

    def add_keywords(words)

      return if self.locality > 5
      return if words.blank?

      str = ""
      add_keywords = words.downcase.split(//).inject([]) { |arr, word|
        arr << (str += word)
      }
      self.update_attribute(:keywords, self.keywords.concat(add_keywords))
      nil

    end # add_keywords

    private

    def set_keywords

      return if self.locality > 5 || !self.name_changed?

      str = ""
      self.keywords = self.name.downcase.split(//).inject([]) { |arr, word|
        arr << (str += word)
      }
      nil

    end # set_keywords

  end # Area

end # OraculUpdater
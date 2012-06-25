# encoding: utf-8
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

    # Название
    field  :name

    # Поисковые слова
    field  :keywords,             :type => Array

    # Аббревиатура
    field  :abbr

    # Полное обозначение
    field  :abbr_full

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
    field  :postcodes,            :type => Array

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

    # Название региона
    field  :region

    # Название района
    field  :district

    # Название области
    field  :area

    # Название города/деревни (для улицы/дома)
    # Используется для быстрого поиска
    field  :city_name

    # Почтовые коды города/деревни (для улицы/дома)
    # Используется для быстрого поиска
    field  :city_postcodes,       :type => Array

    # Географические координаты (Latitude (Широта) / Longitude (Долгота))
    field  :location,             :type => Array


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

    before_save :set_keywords


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

    scope :find_by_name, ->(name) {

      name = (name || "").sub(/\A[а-я]+\.(\s)?/i, "").clean_whitespaces
      where(:keywords => name.try(:downcase))

    } # find_by_name

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
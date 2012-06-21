# encoding: utf-8
module OraculUpdater

  class Ip

    include Mongoid::Document

    store_in collection: "ips"

    # Ревизия (версия)
    field  :revision,     :type => Integer, :default => 0

    # Начало диапазона (левая граница)
    field  :lft,          :type => Integer, :default => 0

    # Конец диапазона (правая граница)
    field  :rgt,          :type => Integer, :default => 0

    # Инедтификатор населенного пункта (из базы Areas)
    field  :area_id,      :type => BSON::ObjectId

    index({

      revision: 1,
      lft:      1,
      rgt:      1

    }, {
      name: "ip_indx_1"
    })

    index({ revision: 1 })

  end # Ip

end # OraculUpdater
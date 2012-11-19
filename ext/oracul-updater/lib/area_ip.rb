# encoding: utf-8
module OraculUpdater

  class AreaIp

    include Mongoid::Document

    store_in collection: "area_ips"

    # Ревизия (версия)
    field  :revision,     :type => Integer, :default => 0

    # Начало диапазона (левая граница)
    field  :lft,          :type => Integer, :default => 0

    # Конец диапазона (правая граница)
    field  :rgt,          :type => Integer, :default => 0

    # Инедтификатор населенного пункта (из базы Areas)
    field  :area_id,      :type => ::Moped::BSON::ObjectId

    index(

      {
        revision: 1,
        lft: 1,
        rgt: 1,
        area_id: 1
      }, {
        name:   "area_ip_indx",
        unique: true
      }
    )

    index(

      {
        revision: 1,
        lft: 1,
        rgt: 1
      }, {
        name: "area_ip_indx2"
      }

    )

    index({ revision: 1 })

    class << self

      def search(ip)

        ip = ip.ip_to_int if ip.is_a?(::String)
        where(:rgt.gte => ip, :lft.lte => ip)

      end # search

      def city(ip)

        r = search(ip).first
        r ? ::OraculUpdater::Area.find(r.area_id) : nil

      end # city

    end # class << self

  end # Ip

end # OraculUpdater
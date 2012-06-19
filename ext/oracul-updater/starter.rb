#!/usr/bin/env ruby
# encoding: utf-8
require 'mongoid'
require 'dbf'

ENV["MONGOID_ENV"] = 'production'

Mongoid.load!( File.join(::File.dirname(__FILE__), "config", "mongoid.yml") )
Mongoid.logger.level = Logger::WARN

require File.expand_path('../lib/ext',    __FILE__)
require File.expand_path('../lib/area',   __FILE__)
require File.expand_path('../lib/kladr',  __FILE__)
require File.expand_path('../lib/ips',    __FILE__)

OraculUpdater::Area.create_indexes

# arj e BASE.ARJ

kladr = ::OraculUpdater::Kladr.new(1)
kladr.
  clear_all.
  convert_areas.
  convert_streets.
  convert_houses.
  set_abbreviation.
  set_city_type.
  set_street_type.
  refresh_area_locations

puts
# encoding: utf-8
require 'unicode'

module StringExt

  def ip_to_int

    return unless self =~ /^((([01]?\d{1,2})|(2([0-4]\d|5[0-5])))\.){3}(([01]?\d{1,2})|(2([0-4]\d|5[0-5])))$/
    bits = self.split(/\./)
    bits[0].to_i*256*256*256 + bits[1].to_i*256*256 + bits[2].to_i*256 + bits[3].to_i

  end # ip_to_int

  def clean_whitespaces
    self.sub(/\A\s+/, "").sub(/\s+\z/, "").gsub(/(\s){2,}/, '\\1')
  end # clean_whitespaces

  def clean_whitespaces!
    self.replace self.clean_whitespaces
  end # clean_whitespaces!

end # StringExt

class String

  include StringExt

  class_eval '
    def downcase
     ::Unicode::downcase(self)
    end # downcase

   def downcase!
     self.replace downcase
   end # downcase!

   def upcase
     ::Unicode::upcase(self)
   end # upcase

   def upcase!
     self.replace upcase
   end # upcase!

   def capitalize
     ::Unicode::capitalize(self)
   end # capitalize

   def capitalize!
     self.replace capitalize
   end # capitalize!
  '

end # String


module CriteriaExt

  # Usage: Item.all.long_query {|obj| puts obj.id }
  # NOTE: don't use this method with 'skip' or 'limit' scopes.
  # Parameters asc/desc will be removed.
  def long_query(step=500)

    self.options[:sort] = [[:_id, :asc]]
    total = self.count
    (total/step + 1).times do |t|
      self.skip(t*step).limit(step).each {|obj| yield(obj) }
    end # times

  end # long_query

end # CriteriaExt

class Mongoid::Criteria

  include CriteriaExt

end # CriteriaExt
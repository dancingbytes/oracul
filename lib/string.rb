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

  def blank?
    self.empty?
  end # blank?

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
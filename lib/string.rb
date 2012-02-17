# encoding: utf-8
require 'unicode'

class String

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
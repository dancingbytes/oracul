# encoding: UTF-8
module NilClassExt

  def blank?
    true
  end # blank?

end # NilClassExt

class NilClass
  include NilClassExt
end
require 'gtk2'

class Color
  @@color_table = Hash.new do |h,k|
    h[k] = Gdk::Color.parse(k)
  end
  def self.[](key)
    @@color_table[key]
  end
end

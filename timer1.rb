#require 'gnomecanvas2'
require 'gtk2'

class Color
  @@color_table = Hash.new do |h,k|
    h[k] = Gdk::Color.parse(k)
  end
  def self.[](key)
    @@color_table[key]
  end
end

class TimerWindow
  def initialize(width, height)
    init_window(width, height)
    init_gc()
    init_color()
  end

  def init_window(width, height, window_type=nil)
    window_type ||= Gtk::Window::TOPLEVEL
    @window = Gtk::Window.new(window_type)
    @window.set_default_size(width,height)
    @window.set_app_paintable(true)
    @window.realize
    set_window_signal
    @window.show_all
  end

  def set_window_signal
    @window.signal_connect("destroy") do
      Gtk.main_quit
    end
    @window.signal_connect("expose_event") do
      draw
    end
  end

  def draw
    width,height = @window.default_size
    @gc.set_rgb_fg_color(Color["blue"])
    @drawable.draw_rectangle(@gc,true,0,0,width,height)
    @gc.set_rgb_fg_color(Color["#00FF00"])
    @drawable.draw_line(@gc,0,0,width,height)
  end

  def init_gc
    @drawable = @window.window
    @gc = Gdk::GC.new(@drawable)
  end

  def init_color
  end
end

def main
  Gtk.init
  timer = TimerWindow.new(400,300)
  Gtk.main
end

main

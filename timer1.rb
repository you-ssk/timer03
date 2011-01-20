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
    init_gc
    init_timer
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

  def init_gc
    @drawable = @window.window
    @gc = Gdk::GC.new(@drawable)
  end

  def init_timer
    @time = Time.now
    Gtk::timeout_add(10) do
      if Time.now - @time > 1.0
        draw_pixmap(@window.window)
        @time = Time.now
      end
      true
    end
  end

  def set_window_signal
    @window.signal_connect("destroy") do
      Gtk.main_quit
    end
    @window.signal_connect("expose_event") do
      draw_pixmap(@window.window)
    end
  end

  def draw(drawable)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    gc.set_rgb_fg_color(Color["blue"])
    drawable.draw_rectangle(gc,true,0,0,width,height)
    gc.set_rgb_fg_color(Color["#00FF00"])
    drawable.draw_line(gc,0,0,width,height)
    gc.set_rgb_fg_color(Color["#FF0000"])
    drawable.draw_line(gc,width,0,0,height)
  end

  def draw_text(drawable)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    font = Pango::FontDescription.new("Ubuntu 40")
    context = Gdk::Pango.context
    context.font_description = font
    layout = Pango::Layout.new(context)
    layout.width = width*Pango::SCALE
    layout.set_alignment(Pango::Layout::ALIGN_CENTER)
    layout.text = Time.now.to_s
    drawable.draw_layout(gc, 0, height/2, layout, Color["red"])
  end

  def draw_pixmap(window)
    width, height = window.size
    pixmap = Gdk::Pixmap.new(window, width, height, -1)
    draw(pixmap)
    draw_text(pixmap)
    gc = Gdk::GC.new(window)
    window.draw_drawable(gc,pixmap,0,0,0,0,width,height)
  end


end

def main
  Gtk.init
  timer = TimerWindow.new(400,300)
  Gtk.main
end

main

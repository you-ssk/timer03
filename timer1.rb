require 'gtk2'
require 'util'

class View
  def initialize(sec)
    @timer = Timer.new(sec)
  end

  def toggle
    @timer.toggle
  end

  def reset
    @timer.reset
  end

  def draw(pixmap)
    draw_bg2(pixmap)
    draw_image(pixmap,'picture.JPG')
    draw_text(pixmap,@timer.remain_text)
  end

  def draw_bg2(drawable)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    gc.set_rgb_fg_color(Color["white"])
    drawable.draw_rectangle(gc,true,0,0,width,height)
    gc.set_rgb_fg_color(Color["red"])
    thickness = 1.0*width/13
    stripe = (0..width).step(thickness*2)
    stripe.each do |s|
      drawable.draw_rectangle(gc,true,s,0,thickness,height)
    end
  end

  def draw_image(drawable,filename)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    pixbuf = Images.scale(filename,width/2,height/2)
    drawable.draw_pixbuf(gc,pixbuf,0,0,width/4,height/4,-1,-1,
                         Gdk::RGB::DITHER_NORMAL, 0, 0)
  end

  def draw_text(drawable,remain_text)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size

    font = Pango::FontDescription.new("Ubuntu")
    font.absolute_size = height/2*Pango::SCALE
    context = Gdk::Pango.context
    context.font_description = font
    layout = Pango::Layout.new(context)
    layout.width = width*Pango::SCALE
    layout.set_alignment(Pango::Layout::ALIGN_CENTER)
    layout.text = remain_text
    extents = layout.pixel_extents
    shadow_x = 4
    shadow_y = 3
    x = 0
    y = height/2-(extents[1].height/2)
    drawable.draw_layout(gc, x+shadow_x, y+shadow_y, layout, Color["maroon"])
    drawable.draw_layout(gc, x, y, layout, Color["darkorange"])
  end
end

class TimerWindow
  def initialize(width, height)
    init_window(width, height)
    init_timer
    @window.show_all
    @views = [View.new(30), View.new(10)]
  end

  def init_window(width, height, window_type=nil)
    @pixmap = nil
    window_type ||= Gtk::Window::TOPLEVEL
    @window = Gtk::Window.new(window_type)
    @window.set_default_size(width,height)
    @window.set_app_paintable(true)
    @window.realize
    set_window_signal(@window)
  end

  def init_timer
    Gtk::timeout_add(100) do
      draw_timer(@window.window)
      true
    end
  end

  def toggle_timer
    @views[0].toggle
  end

  def reset_timer
    @views[0].reset
  end

  def next_timer
    @views.each{|v| v.reset}
    @views.push(@views.shift)
  end

  def set_window_signal(window)
    window.signal_connect("destroy") do
      Gtk.main_quit
    end
    window.signal_connect("expose_event") do
      draw_timer(window.window)
    end
    window.signal_connect("configure_event") do
      draw_timer(window.window)
    end
    window.signal_connect("key_press_event") do |win,evt|
      case evt.keyval
      when Gdk::Keyval::GDK_Return
        toggle_timer
      when Gdk::Keyval::GDK_space
        reset_timer
      when Gdk::Keyval::GDK_n
        next_timer
      when Gdk::Keyval::GDK_Escape
        win.unfullscreen
      when Gdk::Keyval::GDK_F11
        win.fullscreen
      end
    end
  end

  def draw_timer(window)
    pixmap = get_pixmap(window)
    @views[0].draw(pixmap)
    gc = Gdk::GC.new(window)
    width, height = window.size
    window.draw_drawable(gc,pixmap,0,0,0,0,width,height)
  end

  def get_pixmap(window)
    if !@pixmap || @pixmap.size != window.size
      width, height = window.size
      @pixmap = Gdk::Pixmap.new(window, width, height, -1)
    else
      @pixmap
    end
  end
end

def main
  Gtk.init
  timer = TimerWindow.new(400,300)
  Gtk.main
end

main

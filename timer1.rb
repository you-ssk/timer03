require 'gtk2'
require 'util'

module View
  def draw_bg(drawable)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    gc.set_rgb_fg_color(Color["cadetblue"])
    drawable.draw_rectangle(gc,true,0,0,width,height)
    gc.set_rgb_fg_color(Color["#00FF00"])
    drawable.draw_line(gc,0,0,width,height)
    gc.set_rgb_fg_color(Color["#FF0000"])
    drawable.draw_line(gc,width,0,0,height)
  end

  def draw_bg2(drawable)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    gc.set_rgb_fg_color(Color["white"])
    drawable.draw_rectangle(gc,true,0,0,width,height)
    gc.set_rgb_fg_color(Color["red"])
    step = 1.0*width/12
    stripe = (0..width).step(step*2)
    stripe.each do |s|
      drawable.draw_rectangle(gc,true,s,0,step,height)
    end
  end

  def draw_image(drawable,filename)
    width,height = drawable.size
    pixbuf = Images.scale(filename,width/2,height/2)
    gc = Gdk::GC.new(drawable)
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
    drawable.draw_layout(gc, 0, height/2-(extents[1].height/2), layout, Color["darkorange"])
  end
end

class TimerWindow
  include View
  def initialize(width, height)
    init_window(width, height)
    init_timer
    init_images
    @window.show_all
  end

  def init_window(width, height, window_type=nil)
    @pixmap = nil
    window_type ||= Gtk::Window::TOPLEVEL
    @window = Gtk::Window.new(window_type)
    @window.set_default_size(width,height)
    @window.set_app_paintable(true)
    @window.realize
    set_window_signal(@window)
    p @window.window
  end

  def init_timer
    @timer = Timer.new(10)
    Gtk::timeout_add(100) do
      draw_pixmap(@window.window)
      true
    end
  end

  def init_images
    Images['picture.JPG']
  end


  def toggle_timer
    @timer.toggle
  end

  def reset_timer
    @timer.reset
  end

  def set_window_signal(window)
    window.signal_connect("destroy") do
      Gtk.main_quit
    end
    window.signal_connect("expose_event") do
      draw_pixmap(window.window)
    end
    window.signal_connect("configure_event") do
      draw_pixmap(window.window)
    end
    window.signal_connect("key_press_event") do |win,evt|
      case evt.keyval
      when Gdk::Keyval::GDK_Return
        toggle_timer
      when Gdk::Keyval::GDK_space
        reset_timer
      when Gdk::Keyval::GDK_Escape
        win.unfullscreen
      when Gdk::Keyval::GDK_F11
        win.fullscreen
      end
    end
  end

  def draw_pixmap(window)
    pixmap = get_pixmap(window)
    draw_bg2(pixmap)
    draw_image(pixmap,'picture.JPG')
    draw_text(pixmap,@timer.remain_text)
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

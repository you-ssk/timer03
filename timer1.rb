# -*- coding: utf-8 -*-
require 'gtk2'
require 'util'

class View
  def initialize(sec,order)
    @timer = Timer.new(sec)
    @order = order
  end

  def toggle
    @timer.toggle
  end

  def reset
    @timer.reset
  end

  def order(n)
    @order[n]
  end
end

class TimerView < View
  include Pattern

  def draw(drawable)
    remain = @timer.remain
    remain_text = @timer.remain_text(remain)
    if remain > 6
      fill(drawable,"#7E3728")
      draw_text(drawable, "とちぎRuby会議\n50回記念", ["#7E3728","#7E5E50"])
      draw_ring(drawable, remain, ["#6E6F37","#E18AA2"])
      draw_text(drawable, remain_text, ["#FF9900","#FFCC00"])
    else
      fill(drawable,"white")
      draw_text(drawable, "拍手\n準備", ["#7E3728","#7E5E50"])
      draw_text(drawable, sprintf("%1d",remain), ["#FF9900","#FFCC00"])
    end
  end
end


class IntervalView < View
  include Pattern

  def draw(drawable)
    draw_stripe(drawable, ["white","red"])
#    draw_text(drawable, "とちぎRuby会議\n50回記念", ["grey"])
    draw_text(drawable, order(2)[:name], ["grey"])
#    draw_image(drawable, 'picture.JPG')
    draw_text(drawable, @timer.remain_text, ["#990000"])
  end

  def draw_image(drawable,filename)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    pixbuf = Images.scale(filename,width/2,height/2)
    drawable.draw_pixbuf(gc,pixbuf,0,0,width/4,height/4,-1,-1,
                         Gdk::RGB::DITHER_NORMAL, 0, 0)
  end
end

class TimerWindow
  def initialize(width, height, order)
    @order = order
    @pixmap = nil
    @window = init_window(width, height)
    @views = [TimerView.new(10,@order), IntervalView.new(10,@order)]
    start_timer(@window)
  end

  def init_window(width, height)
    w = Gtk::Window.new(Gtk::Window::TOPLEVEL)
    w.set_default_size(width,height)
    w.set_app_paintable(true)
    w.realize
    set_window_signal(w)
    w
  end

  def start_timer(window)
    Gtk::timeout_add(100) do
      draw_timer(window.window)
      true
    end
    window.show_all
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
end

def main
  order = Order.new
  DRb.start_service('druby://:12345',order)
  order.to_hash.sort.each{|e| p e.to_a}
  Gtk.init
  timer = TimerWindow.new(400,300,order)
  Gtk.main
end

main

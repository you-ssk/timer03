# -*- coding: utf-8 -*-
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
  def add_time(n)
    @timer.add_time(n)
  end
end

class TimerView < View
  include Pattern

  def draw(drawable)
    remain = @timer.remain
    remain_text = @timer.remain_text(remain)
    if remain > 6
      fill(drawable,"#000000")
      draw_text(drawable, "とちぎRuby会議03", ["#303030","#181818"])
      draw_ring(drawable, remain, ["#E18494","#ff4500"])
      width,height = drawable.size
      rect = [0,height/4,width,height/2]
      draw_text_at(drawable, remain_text, ["#FFCC00", "#808000"],rect)
    elsif remain > 1
      fill(drawable,"#FFFFCC")
      draw_text(drawable, "拍手\n準備", ["#FFED4F","#994701"])
      draw_text(drawable, sprintf("%1d",remain), ["#FF9900","#FFCC00"])
    else
      fill(drawable,"white")
      draw_text(drawable, "拍手", ["#FFED4F","#994701"])
      draw_text(drawable, sprintf("%1d",remain), ["#FF9900","#FFCC00"])
    end
  end
end

class TimerWindow
  def initialize(width, height)
    @pixmap = nil
    @window = init_window(width, height)
    @view = TimerView.new(30)
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
    Gtk::timeout_add(250) do
      draw_timer(window.window)
      true
    end
    window.show_all
  end

  def toggle_timer
    @view.toggle
  end

  def reset_timer
    @view.reset
  end

  def add_time(n)
    @view.add_time(n)
  end

  def draw_timer(window)
    pixmap = get_pixmap(window)
    @view.draw(pixmap)
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
      when Gdk::Keyval::GDK_plus
        add_time(30)
      when Gdk::Keyval::GDK_minus
        add_time(-30)
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
end

def main
  Gtk.init
  timer = TimerWindow.new(800,600)
  Gtk.main
end

main

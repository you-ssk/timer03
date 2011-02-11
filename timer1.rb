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

  def now
    @order.now
  end
end

class TimerView < View
  include Pattern

  def draw(drawable)
    remain = @timer.remain
    remain_text = @timer.remain_text(remain)
    if remain > 4
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
    draw_image(drawable, 'picture.JPG')
    draw_text(drawable, @timer.remain_text, ["#ffb6c1"])
    draw_text(drawable, now[:name]+"\n"+now[:title], ["black"])
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
    @views = [IntervalView.new(10,@order), TimerView.new(10,@order)]
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
    if @views[0].class == IntervalView
      @order.next
    end
  end

  def prev_timer
    @views.each{|v| v.reset}
    @views.unshift(@views.pop)
    if @views[0].class == IntervalView
      @order.prev
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
      when Gdk::Keyval::GDK_p
        prev_timer
      when Gdk::Keyval::GDK_Escape
        win.unfullscreen
      when Gdk::Keyval::GDK_F11
        win.fullscreen
      end
    end
  end
end

def main
  entry =
    [{:no=>1,:name=>"track8",:title=>"Darkness on the Edge of Gunma"},
     {:no=>2,:name=>"りっく",:title=>"去年の社会人一年生のRuby研修"},
     {:no=>3,:name=>"Glass_saga",:title=>"Reudy on Ruby1.9"},
     {:no=>4,:name=>"坪井創吾",:title=>"タイトル未定"},
     {:no=>5,:name=>"樽家昌也",:title=>"タイトル未定"},
     {:no=>6,:name=>"五十嵐邦明",:title=>"北陸.rb x 高専カンファレンス"}]
  order = Order.new(entry)
  DRb.start_service('druby://:12345',order)
  Gtk.init
  timer = TimerWindow.new(400,300,order)
  Gtk.main
end

main

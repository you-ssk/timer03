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
    if remain > 6
      fill(drawable,"#000000")
      draw_text(drawable, "とちぎRuby会議03", ["#303030","#181818"])
      draw_ring(drawable, remain, ["#E18494","#ff4500"])
      draw_text(drawable, remain_text, ["#FFCC00", "#FF7A4F"])
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

class IntervalView < View
  include Pattern

  def draw(drawable)
    draw_stripe(drawable, ["white","red"])
    draw_image(drawable, now[:picture]) if now[:picture]
    w,h = drawable.size
    f = 0.3
    rect = [0,0,w/1.3,h*f]
    draw_text_at(drawable, now[:name], ["black"], rect)
    rect = [0,h-h*f,w,h*f]
    draw_text_at(drawable, now[:title], ["black"], rect)
    rect = [0,h/2-h/5,w,h/2.5]
    draw_text_at(drawable, @timer.remain_text, ["#ffb6c1","#cd5c5c"],rect)
  end

  def draw_image(drawable,filename)
    return unless Images[filename]
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    factor = 0.3
    factor = 0.45 if filename == 'tsuboi2.jpg'
    margin = 10
    pixbuf = Images.scale(filename,width*factor,height*factor)
    im = Images[filename]
    iw,ih = im.width, im.height
    drawable.draw_pixbuf(gc,pixbuf,0,0,
                         width-iw-margin,margin,-1,-1,
                         Gdk::RGB::DITHER_NORMAL, 0, 0)
  end
end

class SpView
  include Pattern
  def draw(drawable)
    draw_stripe(drawable, ["white","red"])
    draw_image(drawable)
  end

  def draw_image(drawable)
    filename = 'IMGP2401.jpg'
    return unless Images[filename]
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    margin = width*0.02
    pixbuf = Images.scale(filename,width-margin*2,height-margin)
    iw,ih = pixbuf.width,pixbuf.height
    is = [(width-iw)/2,(height-ih)/2]
    drawable.draw_pixbuf(gc,pixbuf,0,0,
                         is[0],is[1],-1,-1,
                         Gdk::RGB::DITHER_NORMAL, 0, 0)
    rect = [is[0]+iw*0.6, is[1], iw*0.4, ih*0.3]
    draw_text_at(drawable,'池澤さん',['white','red'], rect)
    rect = [is[0]+iw*0.6, is[1]+ih*0.6, iw*0.4, ih*0.3]
    draw_text_at(drawable,'祝♥還暦',['white','red'], rect)
  end

end

class TimerWindow
  def initialize(width, height, order)
    @order = order
    @pixmap = nil
    @window = init_window(width, height)
    @views = [IntervalView.new(30,@order), TimerView.new(300,@order)]
    @sp = false
    @spview = SpView.new
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
    Gtk::timeout_add(200) do
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
    if @sp
      @spview.draw(pixmap)
    else
      @views[0].draw(pixmap)
    end
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
      when Gdk::Keyval::GDK_I
        @sp = !@sp
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
    [
     {:no=>1,:name=>"track8",:title=>"Darkness on the Edge of Gunma",:picture=>"track8.jpg"},
     {:no=>2,:name=>"リック・サンダース",:title=>"去年の社会人一年生のRuby研修",:picture=>"jolteon_flygon.png"},
     {:no=>3,:name=>"Glass_saga",:title=>"Reudy on Ruby1.9",:picture=>"Glass_saga.jpg"},
     {:no=>4,:name=>"坪井創吾",:title=>"タイトル未定",:picture=>"tsuboi2.jpg"},
     {:no=>5,:name=>"樽家昌也",:title=>"Rubyと構文解析と私",:picture=>"tarui.JPG"},
     {:no=>6,:name=>"五十嵐邦明",:title=>"北陸.rb x 高専カンファレンス",:picture=>"igaiga.jpg"}
    ]
  order = Order.new(entry)
  entry.each do |e|
    Images[e[:picture]] if e[:picture]
  end
  DRb.start_service('druby://:12345',order)
  Gtk.init
  timer = TimerWindow.new(800,600,order)
  Gtk.main
end

main

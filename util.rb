# -*- coding: utf-8 -*-
require 'gtk2'

class Color
  @@color_table = Hash.new do |h,k|
    h[k] = Gdk::Color.parse(k)
  end

  def self.[](key)
    @@color_table[key]
  end
end

class Images
  @@image_table = Hash.new do |h,k|
    h[k] = {
      :org=>Gdk::Pixbuf.new(k),
      :scaled=>nil
    }
  end

  def self.[](key)
    img = @@image_table[key]
    if img[:scaled]
      img[:scaled]
    else
      img[:org]
    end
  end

  def self.scale(key,dest_width,dest_height)
    if self[key].width != dest_width
      org_image = @@image_table[key][:org]
      scale = 1.0*dest_width/org_image.width
      @@image_table[key][:scaled] = 
        org_image.scale(scale*org_image.width,scale*org_image.height)
    end
    self[key]
  end
end

class Timer
  def initialize(sec)
    @sec = sec
    reset
  end

  def start(time)
    @state = :start
    @start_time = time
    p @state
  end

  def pause(time)
    @state = :pause
    @elapse = time - @start_time + @elapse
    p @state
  end

  def expire
    @state = :expire
    p @state
  end

  def reset
    @state = :stop
    @elapse = 0
    p @state
  end

  def remain
    case @state
    when :stop
      @sec
    when :start
      r = @start_time + @sec - @elapse - Time.now
      if r > 0
        r
      else
        expire
        remain
      end
    when :pause
      @sec - @elapse
    when :expire
      0
    end
  end

  def remain_text(fsec=nil)
    r = fsec ? fsec : remain
    m,s = remain.to_i.divmod(60)
    sprintf("%01d:%02d",m,s)
  end

  def toggle
    case @state
    when :stop
      start(Time.now)
    when :start
      pause(Time.now)
    when :pause
      start(Time.now)
    end
  end
end

module Pattern
  def background(drawable, color)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    gc.set_rgb_fg_color(Color[color])
    drawable.draw_rectangle(gc,true,0,0,width,height)
  end

  def draw_stripe(drawable, colors)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    gc.set_rgb_fg_color(Color[colors[0]])
    drawable.draw_rectangle(gc,true,0,0,width,height)
    gc.set_rgb_fg_color(Color[colors[1]])
    thickness = 1.0*width/13
    stripe = (0..width).step(thickness*2)
    stripe.each do |s|
      drawable.draw_rectangle(gc,true,s,0,thickness,height)
    end
  end

  def draw_ring(window,remain,colors)
    c = window.create_cairo_context
    c.set_source_color(colors[0])
    width, height = window.size
    c.set_line_width(height/6)
    step = 3
    from = -90+step*1.5
    to = 359+from
    angles = from.step(to,step).to_a.map{|a| a*Math::PI/180}.each_slice(2).to_a.reverse
    angles.each do |angle|
      c.arc(width/2, height/2, width/4,
            angle[0],angle[1])
      c.stroke
    end
    c.set_source_color(colors[1])
    angle = angles[remain.to_i % 60]
    c.arc(width/2, height/2, width/4,
          angle[0], angle[1])
    c.stroke
  end

  def draw_text(drawable,text,colors)
    gc = Gdk::GC.new(drawable)
    width,height = drawable.size
    font = Pango::FontDescription.new("Ubuntu")
    font.absolute_size = height*Pango::SCALE
    context = Gdk::Pango.context
    context.font_description = font
    layout = Pango::Layout.new(context)
    layout.font_description = font
    layout.width = width*Pango::SCALE
    layout.set_alignment(Pango::Layout::ALIGN_CENTER)
    layout.wrap = Pango::Layout::WRAP_WORD_CHAR
    layout.text = text
    font_size(layout,width,height)
    shadow_x = 4
    shadow_y = 3
    x = 0
    y = height/2-(layout.pixel_size[1]/2)
    if colors[1]
      drawable.draw_layout(gc, x+shadow_x, y+shadow_y, layout, Color[colors[1]])
    end
    drawable.draw_layout(gc, x, y, layout, Color[colors[0]])
  end

  def font_size(layout, w, h)
    font = layout.font_description
    while true
      pixel_size = layout.pixel_size
      if pixel_size[0] < w && pixel_size[1] < h
        break
      else
        font.absolute_size = 0.9*font.size
      end
      layout.font_description = font
    end
  end


end

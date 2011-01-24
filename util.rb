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

  def remain_text
    m,s = remain.to_i.divmod(60)
    sprintf("%02d:%02d",m,s)
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

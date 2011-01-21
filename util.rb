require 'gtk2'

class Color
  @@color_table = Hash.new do |h,k|
    h[k] = Gdk::Color.parse(k)
  end
  def self.[](key)
    @@color_table[key]
  end
end

class Timer
  def initialize(sec)
    @sec = sec
    reset
  end

  def start
    @state = :start
    @start_time = Time.now
    p @state
  end

  def pause
    @state = :pause
    @elapse = Time.now - @start_time + @elapse
    p @state, @elapse
  end

  def stop
  end

  def reset
    @state = :stop
    @elapse = 0
  end

  def remain
    if @state == :stop
      @sec
    elsif @state == :start
      @start_time + @sec - @elapse - Time.now
    elsif @state == :pause
      @sec - @elapse
    end
  end

  def toggle
    if @state == :stop
      start
    elsif @state == :start
      pause
    elsif @state == :pause
      start
    end
  end
end

#require 'gnomecanvas2'
require 'gtk2'

class TimerWindow
  def initialize(width, height)
    init_window(width, height)
  end

  def init_window(width, height, window_type=nil)
    window_type ||= Gtk::Window::TOPLEVEL
    @window = Gtk::Window.new(window_type)
    @window.set_default_size(width,height)
    set_window_signal
    @window.show
  end

  def set_window_signal
    @window.signal_connect("destroy") do
      Gtk.main_quit
    end
  end

end

def main
  Gtk.init
  timer = TimerWindow.new(400,300)
  Gtk.main
end

main

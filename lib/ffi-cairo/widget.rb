module Cairo

  class Widget
    attr_reader :pos

    def initialize(opts={}, *a)
      create(opts, *a)
      set_pos(*opts.values_at(:x, :y).map{|i| i || 0 }) unless @pos
      @width, @height = 100, 100 unless @width && @height
      klass = case Cairo.render_type
              when :x11; Cairo::DataSurface
              when :gl;  Cairo::OpenGL_Surface
              else raise "no Cairo.render_type found!"
              end
      @surface = klass.new(@width, @height)
      @surface.callback = method(:callback)
    end

    def create(opts, *a); end
    def set_pos(x,y); @pos = [x, y]; end
    def callback(cairo, width, height, cairo_helper); end

    def render; @surface.render; end
    def draw(*a); @surface.draw(*a); end
    def redraw(*a); @surface.surface && @surface.redraw(*a); end
    def destroy; @surface.destroy; end
  end


  class Widgets
    attr_reader :widgets
    def initialize; @widgets, @timers = {}, {}; end
    def add(name, widget); @widgets[name] = widget; end
    def draw(cairo_context=nil)
      @widgets.each{|name,widget|
        case Cairo.render_type
        when :x11
          widget.redraw(cairo_context, *widget.pos)

        when :gl
          GL.glPushMatrix
            widget.redraw(cairo_context, *widget.pos)
          GL.glPopMatrix

        else raise "no Cairo.render_type found!"
        end
      }
    end
    def render_all; @widgets.each{|name,widget| widget.render }; end
    def [](name); @widgets[name]; end
    def render(name); @widgets[name].render; end

    def fire_timers!
      now, run_now = Time.now.to_f, []
      @timers.each{|name,timers|
        timers.each{|state|
          if state[:next_tick] <= now
            run_now << [name, state[:method]] # queue run
            state[:next_tick] = now + state[:interval] # enqueue next tick
          end
        }
      }
      run_now.each{|name,method| @widgets[name].send(method) }
    end

    def add_timer(name, interval, method)
      @timers[name] ||= []
      @timers[name] << { method: method, interval: interval, next_tick: Time.now.to_f + interval }
    end
  end


  class << self
    attr_accessor :render_type

    def create_window(name)
      p [:create_window, name, Cairo.render_type]
      klass = case Cairo.render_type
              when :gl;   Cairo::GL::X11::Window
              when :x11;  Cairo::X11::Window
              else raise "no Cairo.render_type found!"
              end
      klass.new(name)
    end
  end

end

require 'ffi'
require 'ffi-cairo.rb'

module X11
  extend FFI::Library
  ffi_lib 'X11'
  attach_function :XOpenDisplay, [:string], :pointer
  attach_function :XCreateSimpleWindow, [:pointer, :uint, :int, :int, :uint, :uint, :uint, :ulong, :ulong], :uint
  attach_function :XSelectInput, [:pointer, :uint, :long], :int
  attach_function :XMapWindow, [:pointer, :uint], :int
  attach_function :XNextEvent, [:pointer, :pointer], :int
  attach_function :XPending, [:pointer], :int
  attach_function :XStoreName, [:pointer, :uint, :string], :int
  attach_function :XFlush, [:pointer], :void
  attach_function :XCreateGC, [:pointer, :uint, :ulong, :pointer], :pointer
  attach_function :XCopyArea, [:pointer, :uint, :uint, :pointer, :int, :int, :uint, :uint, :int, :int], :void
  attach_function :XCreatePixmap, [:pointer, :uint, :uint, :uint, :int], :uint


  XA_ATOM     = 4 # ((Atom) 4)
  PropModeReplace = 0
  StructureNotifyMask      = 1<<17
  ExposureMask             = 1<<15

  module_function
  def get_display(display = nil); XOpenDisplay(display || ENV['DISPLAY']); end
  @ptr_size = FFI.type_size(:pointer)
  def ptr_size; @ptr_size; end
  def ScreenOfDisplay(d, i);   d.get_pointer(@ptr_size == 4 ? 140 : 232);       end
  def RootWindow(d, i=0);      ScreenOfDisplay(d,i).get_uint(2*@ptr_size);      end
  def DefaultBlack(d, i=0);    ScreenOfDisplay(d,i).get_uint(13*@ptr_size);     end
  def DefaultVisual(d, i=0);   ScreenOfDisplay(d,i).get_pointer(@ptr_size == 4 ? 40 : 64); end
  def DefaultDepth(d, i=0);    ScreenOfDisplay(d,i).get_uint(@ptr_size == 4 ? 36 : 56); end


  class Window
    attr_reader :win, :context, :width, :height, :running
    attr_accessor :parent

    def initialize(window_name, display_name=nil)
      @dpy = X11.get_display(display_name)
      @root = X11.RootWindow(@dpy, 0)
      w, h = 640, 480
      create_window(w, h, window_name)
      create_surface(w, h)
      init_xevents
    end

    def create_window(width, height, name="glx-window")
      @width, @height, @window_name = width, height, name
      set_ratio(@width, @height)
      @win = X11.XCreateSimpleWindow(@dpy, @root, 0, 0, @width, @height, 0, 0, X11.DefaultBlack(@dpy))
      X11.XMapWindow(@dpy, @win)
      X11.XSelectInput(@dpy, @win, X11::StructureNotifyMask | X11::ExposureMask)
      X11.XStoreName(@dpy, @win, name.to_s)
    end

    def create_surface(width, height, x11=true)
      create_pixmap(width, height)
      (Cairo.cairo_surface_destroy(@surface); @surface = nil) if @surface
      #@surface = Cairo.cairo_image_surface_create(Cairo::CAIRO_FORMAT_ARGB32, width, height)
      #@buf = Cairo.cairo_image_surface_get_data(@surface)
      @surface = Cairo.cairo_xlib_surface_create(@dpy, @pixmap, X11.DefaultVisual(@dpy), width, height)
      (Cairo.cairo_destroy(@cairo); @cairo = nil) if @cairo
      @cairo = Cairo.cairo_create(@surface)
      @cairo_helper = nil if @cairo_helper
      @cairo_helper = Cairo::ContextHelper.new(@cairo)
    end

    def create_pixmap(width, height)
      @pixmap = X11.XCreatePixmap(@dpy, @win, @width, @height, X11.DefaultDepth(@dpy))
      @gc = X11.XCreateGC(@dpy, @win, 0, nil)
    end

    def draw(&blk)
      Cairo.clear_background(@cairo, 0.2, 0.2, 0.2)
      blk.call(@cairo_helper, @cairo)
      draw_x11
    end

    def draw_x11
      X11.XCopyArea(@dpy, @pixmap, @win, @gc, 0, 0, @width, @height, 0, 0)
      X11.XFlush(@dpy)
    end

    def close
      X11.XDestroyWindow(@dpy, @win)
      X11.XCloseDisplay(@dpy)
    end

    def set_ratio(width, height)
      @ratio = (width>height) ? (width/height.to_f) : (height/width.to_f)
    end

    def init_xevents
      @xev = FFI::MemoryPointer.new(:uint8, 24*X11.ptr_size)
      @xev_ahead = FFI::MemoryPointer.new(:uint8, 24*X11.ptr_size)
    end

    def xev_reshape
      return unless @win or @win == @xev.get_uint(X11.ptr_size == 4 ? 20 : 32) # win != xconfigure.window
      width, height = @xev.get_array_of_uint(X11.ptr_size == 4 ? 32 : 56, 2)
      if (@width != width) || @height != height
        @width, @height = width, height
        set_ratio(@width, @height)
        p ['xev_reshape', @width, @height, @ratio]
        $xlib_window_size = { w: @width, h: @height }
        create_surface(@width, @height)
      end
    end

    def step_events(max_steps=20)
      steps = 0
      while X11.XPending(@dpy) != 0
        X11.XNextEvent(@dpy, @xev)
        case @xev.get_uint(0) # xev.type
        when 22;  xev_reshape;
        end
        (steps > max_steps) ? break : steps+=1
      end
      steps
    end

    def render_loop(wait=1.0, show_stat=false, &draw_block)
      @running = true
      while @running
        t = Time.now
        step_events
        draw(&draw_block)
        took  = (Time.now - t).to_f
        delay = wait ? (wait - took) : 0.0; delay=0 if delay < 0.0
        p [:took, took, :delay, delay] if show_stat
        sleep(delay) if wait
      end
    end
    alias loop render_loop
  end
end

module Cairo
  class DataSurface
    attr_reader :surface, :cairo, :cairo_helper, :width, :height

    def initialize(w,h, &blk)
      @width, @height = w, h
      @callback = blk
    end

    def resize(w, h); @width, @height = w, h; :repeat; end

    def destroy
      (Cairo.cairo_surface_destroy(@surface); @surface = nil) if @surface
      (Cairo.cairo_destroy(@cairo); @cairo = nil) if @cairo
      @cairo_helper = nil if @cairo_helper
    end

    def create_surface(width=@width, height=@height)
      destroy
      @surface = Cairo.cairo_image_surface_create(Cairo::CAIRO_FORMAT_ARGB32, width, height)
      @cairo = Cairo.cairo_create(@surface)
      @cairo_helper = Cairo::ContextHelper.new(@cairo)
    end

    def data
      @buf = nil if @buf
      @buf = Cairo.cairo_image_surface_get_data(@surface)
    end

    def render
      loop{
        create_surface
        break unless @callback.call(@cairo, @width, @height, @cairo_helper) == :repeat
      }
    end

    def draw(cairo_ctx=nil, x=0, y=0)
      render
      draw_on_parent_surface(cairo_ctx, x, y)
    end

    def draw_on_parent_surface(cairo_ctx=nil, x=0, y=0)
      if cairo_ctx
        Cairo.cairo_set_source_surface(cairo_ctx, @surface, x, y)
        Cairo.cairo_paint(cairo_ctx)
      end
    end
    alias redraw draw_on_parent_surface
  end
end


if __FILE__ == $0
clock = Cairo::DataSurface.new(150, 150){|cr, w, h, c|
  #c.background(0.5, 0.5, 0.5)
  #c.background_border(255, 100, 0, w, h)
  c.set_line_width(2.0)
  
  full_circle = proc{|xc,yc,radius|
    a1, a2 = -90.0 * (Math::PI/180.0), 360.0 * (Math::PI/180.0)
    c.arc(xc, yc, radius, a1, a2); c.stroke
  }

  xc, yc = w/2.0, h/2.0
  radius = 50
  angle2 = -(90.0) * (Math::PI/180.0)

  time = Time.now

  c.set_source_rgb(0.4, 0.4, 0.4)

  radius += 3
  angle1 = -(90-(360 * ((time.sec % 60) / 60.0))) * (Math::PI/180.0)
  c.arc(xc, yc, radius, angle2, angle1)
  #c.rel_move_to(-15, 0); c.show_text("#{time.sec}"); c.set_source_rgb(255, 100, 0)
  c.set_source_rgb(0.4, 0.4, 0.4)
  c.stroke

  radius += 7
  angle1 = -(90-(360 * ((time.min + (time.sec/60.0)) / 60.0))) * (Math::PI/180.0)
  c.arc(xc, yc, radius, angle2, angle1)
  c.stroke

  radius += 5
  angle1 = -(90-(360 * (((time.hour % 12) + (time.min / 60.0))/ 12.0))) * (Math::PI/180.0)
  c.arc(xc, yc, radius, angle2, angle1)
  c.stroke

  c.set_source_rgb(0.3, 0.3, 0.3)
  full_circle.call(xc,yc,55)
  c.move_to(xc+1,yc-47)
  12.times{
    c.rel_move_to(27.5, 0)
    c.rotate(30 * (Math::PI/180))
    c.rel_line_to(0, 8)
  }
  c.stroke

  c.font_size = 30; c.set_source_rgb(0.3, 0.3, 0.3)
  c.move_to(xc-20,yc-20)
  c.show_text(time.strftime("%d"))

  c.font_size = 14; c.set_source_rgb(0.6, 0.6, 0.6)
  c.move_to(xc-40,yc-5)
  c.show_text(time.strftime("%A"))

  c.font_size = 16; c.set_source_rgb(0.3, 0.3, 0.3)
  c.move_to(xc-36,yc+13)
  c.show_text(time.strftime("%b %Y"))

  c.font_size = 14; c.set_source_rgb(0.6, 0.6, 0.6)
  c.move_to(xc-32,yc+34)
  c.show_text(time.strftime("%H:%M:%S"))
  c.stroke
}


win = X11::Window.new('cairo-canvas')

win.loop(1.0, :debug_time){|cairo|
  #clock.draw(cairo.ctx, 0, 0)
  #clock.draw(cairo.ctx, 150, 0)
  clock.render # render once

  y = -150; (win.height/150.0).floor.times{
    y += 150; x = -150
    (win.width/150.0).floor.times{
      #clock.draw(cairo.ctx, x+=150, y) # render and draw each time
      clock.redraw(cairo.ctx, x+=150, y) # redraw again
    }
  }
}

end # __FILE__ == $0

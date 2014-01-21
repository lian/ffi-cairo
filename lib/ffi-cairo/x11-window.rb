require 'ffi'
require 'ffi-cairo.rb'

module Cairo
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

    def initialize(window_name, display_name=nil, visual_settings=nil, window_type=nil, w=600, h=480, x=0, y=0)
      @dpy = X11.get_display(display_name)
      @root = X11.RootWindow(@dpy, 0)
      create_window(w, h, x, y, window_name)
      create_surface(w, h)
      init_xevents
    end

    def create_window(width, height, x, y, name="glx-window")
      @width, @height, @window_name = width, height, name
      @pos_x, @pos_y = x, y
      set_ratio(@width, @height)
      @win = X11.XCreateSimpleWindow(@dpy, @root, @pos_x, @pos_y, @width, @height, 0, 0, X11.DefaultBlack(@dpy))
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

    def step_events(max_steps=100)
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
end



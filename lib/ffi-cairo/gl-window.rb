require 'ffi'

module Cairo
module GL
module X11
  extend FFI::Library
  ffi_lib 'X11'
  attach_function :XOpenDisplay, [:string], :pointer
  attach_function :XCloseDisplay, [:pointer], :int
  attach_function :XFlush, [:pointer], :pointer

  attach_function :XMapWindow, [:pointer, :uint], :int
  attach_function :XUnmapWindow, [:pointer, :uint], :int
  attach_function :XStoreName, [:pointer, :uint, :string], :int
  attach_function :XSelectInput, [:pointer, :uint, :long], :int
  attach_function :XNextEvent, [:pointer, :pointer], :int
  attach_function :XCreateColormap, [:pointer, :int, :pointer, :int], :pointer

  attach_function :XCreateSimpleWindow, [:pointer, :uint, :int, :int, :uint,
    :uint, :uint, :ulong, :ulong], :uint
  attach_function :XCreateWindow, [:pointer, :uint, :int, :int, :uint, :uint,
    :uint, :int, :uint, :pointer, :ulong, :pointer], :uint

  attach_function :XDestroyWindow, [:pointer, :uint], :int

  attach_function :XPending, [:pointer], :int
  attach_function :XNextEvent, [:pointer, :pointer], :int
  attach_function :XEventsQueued, [:pointer, :uint], :uint
  attach_function :XPeekEvent, [:pointer, :pointer], :void
  attach_function :XLookupKeysym, [:pointer, :uint], :int
  attach_function :XLookupString, [:pointer, :pointer, :int, :pointer, :pointer], :int

  attach_function :XInternAtom, [:pointer, :string, :int], :pointer
  attach_function :XChangeProperty, [:pointer, :int, :pointer, :int, :int, :int, :pointer, :int], :void

  XA_ATOM     = 4 # ((Atom) 4)
  XA_CARDINAL = 6 # ((Atom) 6)
  PropModeReplace = 0

  class XSetWindowAttributes < FFI::Struct
    layout  *[:background_pixmap, :long,
            :background_pixel,  :ulong,
            :border_pixmap,     :long,
            :border_pixel,      :ulong,
            :bit_gravity,       :int,
            :win_gravity,       :int,
            :backing_store,     :int,
            :backing_planes,    :ulong,
            :backing_pixel,     :ulong,
            :save_under,        :int,
            :event_mask,        :long,
            :do_not_propagate_mask, :long,
            :override_mask,     :int,
            :colormap,          :pointer,
            :cursor,            :pointer, ]
  end
  

  module_function
  def get_display(display = nil); XOpenDisplay(display || ENV['DISPLAY']); end

  @ptr_size = FFI.type_size(:pointer)
  def ptr_size; @ptr_size; end

  def ScreenOfDisplay(d, i);   d.get_pointer( @ptr_size == 4 ? 35*4 : 58*4 );  end
  def RootWindow(d, i=0);      ScreenOfDisplay(d,i).get_int(2*@ptr_size);      end

  InputOutput = 1
  None = 0
  MapNotify = 19
  Expose = 12
  ConfigureNotify = 22

  NoEventMask              = 0
  KeyPressMask             = 1<<0
  KeyReleaseMask           = 1<<1
  ButtonPressMask          = 1<<2
  ButtonReleaseMask        = 1<<3
  EnterWindowMask          = 1<<4
  LeaveWindowMask          = 1<<5
  PointerMotionMask        = 1<<6
  PointerMotionHintMask    = 1<<7
  Button1MotionMask        = 1<<8
  Button2MotionMask        = 1<<9
  Button3MotionMask        = 1<<10
  Button4MotionMask        = 1<<11
  Button5MotionMask        = 1<<12
  ButtonMotionMask         = 1<<13
  KeymapStateMask          = 1<<14
  ExposureMask             = 1<<15
  VisibilityChangeMask     = 1<<16
  StructureNotifyMask      = 1<<17
  SubstructureNotifyMask   = 1<<19
  SubstructureRedirectMask = 1<<20
  FocusChangeMask          = 1<<21
  PropertyChangeMask       = 1<<22
  ColormapChangeMask       = 1<<23
  CWBackPixmap             = 1<<0
  CWBackPixel              = 1<<1
  CWBorderPixel            = 1<<3
  CWEventMask              = 1<<11
  CWColormap               = 1<<13
  QueuedAfterReading = 1

  ButtonMotions = (1..5).map{|n| X11.const_get("Button#{n}MotionMask") }


  ffi_lib 'GL'
  attach_function :glXChooseVisual, [:pointer, :int, :pointer], :pointer
  attach_function :glXCreateContext, [:pointer, :pointer, :pointer, :int], :pointer
  #attach_function :glXCreateContextAttribsARB, [:pointer, :pointer, :pointer, :int, :pointer], :pointer
  attach_function :glXDestroyContext, [:pointer, :pointer], :void
  attach_function :glXMakeCurrent, [:pointer, :uint, :pointer], :int
  attach_function :glXSwapBuffers, [:pointer, :uint], :void
  #attach_function :glxWaitX, [], :void

  GLX_RGBA = 4
  GLX_DOUBLEBUFFER = 5
  GLX_BUFFER_SIZE       = 2
  GLX_RED_SIZE          = 8
  GLX_GREEN_SIZE        = 9
  GLX_BLUE_SIZE         = 10
  GLX_ALPHA_SIZE        = 11
  GLX_DEPTH_SIZE        = 12
  GLX_STENCIL_SIZE      = 13
  GLX_ACCUM_RED_SIZE    = 14
  GLX_ACCUM_GREEN_SIZE  = 15
  GLX_ACCUM_BLUE_SIZE   = 16
  GLX_ACCUM_ALPHA_SIZE  = 17


  class FixedStep
    def initialize(window)
      @window = window
      @next_tick, @interpolation = get_tick, 0.0
    end
    def quit; @quit = true; end
    def get_tick; t = Time.now; (t.tv_usec/1000) + (t.tv_sec*1000); end

    TICKS_PER_SECOND = 25.0
    SKIP_TICKS = 1000.0 / TICKS_PER_SECOND
    MAX_FRAMESKIP = 5.0

    def step
      loops_passed = 0 # disable for network games
      while (get_tick > @next_tick) && (loops_passed < MAX_FRAMESKIP)
        @window.update
        @next_tick += SKIP_TICKS
        loops_passed += 1
      end
      @interpolation = (get_tick + SKIP_TICKS - @next_tick) / SKIP_TICKS
      @window.draw(@interpolation)
    end

    def run
      step until @quit
    end
  end

  class Window
    attr_reader :win, :context, :width, :height
    attr_accessor :parent

    def initialize(window_name, display_name=nil, visual_settings=nil, _window_type=:normal)
      @dpy  = X11.get_display(display_name)
      @root = X11.RootWindow(@dpy, 0)

      create_context
      create_window(640, 480, window_name, _window_type)
      make_current

      init_xevents
    end

    def create_window(width, height, name="glx-window", type=:normal)
      @width, @height, @window_name = width, height, name
      set_ratio(@width, @height)

      @swa = X11::XSetWindowAttributes.new
      @swa[:colormap]   = X11.XCreateColormap(@dpy, @root, @visual, X11::None)
      @swa[:event_mask] = ExposureMask | KeyPressMask | \
                          KeyReleaseMask | ButtonPressMask | ButtonReleaseMask | \
                          ButtonMotionMask | StructureNotifyMask | \
                          PointerMotionMask | StructureNotifyMask

      @win = X11.XCreateWindow(@dpy, @root, 0, 0, @width, @height, 0,
        depth=@visual.get_array_of_uint(0, 6).last, X11::InputOutput,
        @visual, CWBackPixel|CWBackPixmap|CWBorderPixel|CWColormap|CWEventMask, @swa)

      window_type(type)
      X11::XStoreName(@dpy, @win, name.to_s)
    end

    def create_child_window(name=nil)
      @child_window ||= {}
      name = "#{@window_name}_child_#{@child_window.size+1}" unless name
      child = @child_window[name] = self.class.new(name)
      child.parent = self
      child.reshape_callback = @reshape_cb
      child.mouse_callback   = @mouse_callback
      child.motion_callback  = @motion_callback
      child
    end

    def create_context
      visual_settings ||= FFI::MemoryPointer.new(:int, 32)
        .put_array_of_int(0, [
          GLX_RGBA,
          GLX_RED_SIZE, 1, GLX_GREEN_SIZE, 1, GLX_BLUE_SIZE, 1,
          GLX_ALPHA_SIZE, 1, GLX_DOUBLEBUFFER, GLX_DEPTH_SIZE, 1,
          GLX_ACCUM_RED_SIZE, 1, GLX_ACCUM_GREEN_SIZE, 1,
          GLX_ACCUM_BLUE_SIZE, 1, GLX_ACCUM_ALPHA_SIZE, 1,
          # GLX_SAMPLES_ARB, GLX_SAMPLES_SGIS, 4
          GLX_BUFFER_SIZE, 1, GLX_DOUBLEBUFFER, GLX_DEPTH_SIZE, 1,
          X11::None
        ])


      #@visual = X11.DefaultVisual(@dpy, 0)
      @visual  = X11.glXChooseVisual(@dpy, 0, visual_settings)
      if X11.respond_to?(:glXCreateContextAttribsARB)
        # http://github.prideout.net/modern-opengl-prezo/
        # http://www.opengl.org/wiki/Tutorial:_OpenGL_3.0_Context_Creation_(GLX)
        context_settings ||= FFI::MemoryPointer.new(:int, 32)
          .put_array_of_int(0, [
            #GLX_CONTEXT_MAJOR_VERSION_ARB, 4,
            #GLX_CONTEXT_MINOR_VERSION_ARB, 2,
            GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
            GLX_CONTEXT_MINOR_VERSION_ARB, 0,
            GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
            X11::None
          ])
        @context = X11.glXCreateContextAttribsARB(@dpy, @visual, nil, context_settings)
      else
        @context = X11.glXCreateContext(@dpy, @visual, nil, 1)
      end
    end

    GLX_CONTEXT_MAJOR_VERSION_ARB = 0x2091
    GLX_CONTEXT_MINOR_VERSION_ARB = 0x2092
    GLX_CONTEXT_PROFILE_MASK_ARB = 0x9126

    def make_current
      X11.glXMakeCurrent(@dpy, @win, (@parent ? @parent.context : @context))
    end

    def xprops; `xprop -id #{@win}`; end

    def map_window!
      (X11::XMapWindow(@dpy, @win); @is_mapped = true) if @dpy && @win
    end

    def unmap_window!
      (X11::XUnmapWindow(@dpy, @win); @is_mapped = nil) if @is_mapped
    end

    def window_type(mode=nil)
      return @window_type unless mode
      @window_type = mode.to_s.upcase
      unmap_window!
      mode = X11.XInternAtom(@dpy, "_NET_WM_WINDOW_TYPE_" + @window_type, 1)
      mode_ptr = FFI::MemoryPointer.new(:pointer).put_pointer(0, mode)
      X11.XChangeProperty(@dpy, @win, X11.XInternAtom(@dpy, "_NET_WM_WINDOW_TYPE", 0),
                          X11::XA_ATOM, 32, X11::PropModeReplace, mode_ptr, 1)
      map_window!
    end

    def close
      @child_window.each{|k,window| window.close } if @child_window
      X11.glXMakeCurrent(@dpy, X11::None, nil)
      X11.glXDestroyContext(@dpy, @context)
      X11.XDestroyWindow(@dpy, @win)
      X11.XCloseDisplay(@dpy)
    end

    def trap_close(&blk)
      Signal.trap("SIGINT") do
        blk.call if blk
        close; exit!
      end
    end

    attr_accessor :kb_callback, :kb_special_callback, :key_autorepeat

    def setup_perspective
      GL.setup_perspective(60, @width, @height)
    end

    def swap_buffers
      X11.glXSwapBuffers(@dpy, @win)
    end

    def default_viewport
      GL.glViewport(0, 0, @width, @height)
    end

    def set_ratio(width, height)
      @ratio = (width>height) ? (width/height.to_f) : (height/width.to_f)
    end

    def init_xevents
      @xev = FFI::MemoryPointer.new(:uint8, 24*X11.ptr_size)
      @xev_ahead = FFI::MemoryPointer.new(:uint8, 24*X11.ptr_size)
      @tc = FFI::MemoryPointer.new(:uint8, 16)
      @key_autorepeat = true
    end

    def xev_reshape
      if @win
        #              win != xconfigure.window
        return unless @win == @xev.get_uint(X11.ptr_size == 4 ? 20 : 32)
        width, height = @xev.get_array_of_uint(X11.ptr_size == 4 ? 32 : 56, 2)
        if (@width != width) || @height != height
          @width, @height = width, height
          set_ratio(@width, @height)

          cb = (@reshape_cb || (@parent && @parent.reshape_cb))
          if cb
            cb.call(width, height)
          else
            p ['xev_reshape', @width, @height, @ratio]
            default_viewport
          end
        end
      end
    end

    KEY_PRESS = 2

    def xev_keyboard(state)
      # https://gist.github.com/1062313 # TODO Mon_Ouie's paste
      type, key = xev_lookup_key(@xev)
      #p [:xev_keyboard, type, [key].pack("C"), state]

      unless @key_autorepeat # xset -q
        if state == 0 && X11.XEventsQueued(@dpy, QueuedAfterReading) > 0
          X11.XPeekEvent(@dpy, @xev_ahead)
          # (nev.type == KeyPress && nev.xkey.time == event->xkey.time && nev.xkey.keycode == event->xkey.keycode)
          if @xev_ahead.get_uint(0) == KEY_PRESS && [type, key] == xev_lookup_key(@xev_ahead)
            X11.XNextEvent(@dpy, @xev_ahead)
            return
          end
        end
      end
      
      cb = case type
           when :normal
             (@kb_callback || (@parent && @parent.kb_callback))
           when :special
             (@kb_special_callback || (@parent && @parent.kb_special_callback))
           end
      cb.call(key, state, 0, 0, 0) if cb
    end

    def xev_lookup_key(event)
      if X11.XLookupString(event, @tc, @tc.size, nil, nil) == 1
        [:normal, @tc.read_uint8]
      else
        [:special, X11.XLookupKeysym(event, 0)]
      end
    end

    def xev_mouse(state)
      cb = (@mouse_callback || (@parent && @parent.mouse_callback))
      return unless cb
      x, y = @xev.get_array_of_uint(X11.ptr_size == 4 ? 32 : 64, 2)
      button = @xev.get_uint(X11.ptr_size == 4 ? 52 : 84)
      cb.call(x, y, button, state == 1 ? :down : :up, self)
    end

    def xev_motion
      cb = (@motion_callback || (@parent && @parent.motion_callback))
      return unless cb
      x, y = @xev.get_array_of_uint(X11.ptr_size == 4 ? 32 : 64, 2)
      button = @xev.get_uint(X11.ptr_size == 4 ? 52 : 80)
      button = (ButtonMotions.index{|i| (button & i) == button } + 1) rescue 0
      #p [:motion, x, y, button]
      cb.call(x, y, button, self)
    end

    def xev_dispatch
      case @xev.get_uint(0) # xev.type
      when 2;   xev_keyboard(1);  # KeyPress
      when 3;   xev_keyboard(0);  # KeyRelease
      when 4;   xev_mouse(1);     # ButtonPress
      when 5;   xev_mouse(0);     # ButtonRelease
      when 6;   xev_motion;       # MotionNotify
      when 22;  xev_reshape;
      #when Expose;
      end; true
    end

    def step_events(max_steps)
      steps = 0
      while X11.XPending(@dpy) != 0
        X11.XNextEvent(@dpy, @xev)
        xev_dispatch
        (steps > max_steps) ? break : steps+=1
      end
      steps
    end

    attr_accessor :update_callback, :draw_callback

    def update
      @update_callback.call
      @child_window.each{|_,window| window.update_callback.call } if @child_window
    end

    def draw(interpolation=1.0)
      @draw_callback.call(interpolation)
      @child_window.each{|_,window| window.draw_callback.call(interpolation) } if @child_window
    end

    def step_loop; update; draw(1.0); end

    def render_loop(wait=1.0, show_stat=false, &draw_block)
      self.update_callback = proc{ step_events(10) }
      self.draw_callback = proc{
        setup_perspective
        GL.clear_color([0.2, 0.2, 0.2, 0.0])
        draw_block.call(nil)
        swap_buffers
      }
      trap_close

      @running = true
      while @running
        t = Time.now
        step_loop
        took  = (Time.now - t).to_f
        delay = wait ? (wait - took) : 0.0; delay=0 if delay < 0.0
        p [:took, took, :delay, delay] if show_stat
        sleep(delay) if wait
      end
    end

  end

end
end
end


module Cairo
module GL
  extend FFI::Library
  GL_FALSE = 0
  GL_TRUE = 1
  GL_FLOAT = 0x1406
  GL_CULL_FACE = 0x0B44
  GL_BACK = 0x0405
  GL_CW = 0x0900
  GL_DEPTH_TEST = 0x0B71
  GL_LEQUAL = 0x0203
  GL_LESS = 0x0201
  GL_COLOR_BUFFER_BIT = 0x00004000
  GL_DEPTH_BUFFER_BIT = 0x00000100
  GL_TRIANGLES = 0x0004
  GL_VENDOR = 0x1F00
  GL_RENDERER = 0x1F01
  GL_VERSION = 0x1F02
  GL_SHADING_LANGUAGE_VERSION = 0x8B8C
  GL_MAX_TEXTURE_SIZE = 0x0D33
  GL_PROJECTION = 0x1701
  GL_MODELVIEW = 0x1700
  GL_VERTEX_ARRAY = 0x8074
  GL_NORMAL_ARRAY = 0x8075
  GL_COLOR_ARRAY = 0x8076
  GL_TEXTURE_COORD_ARRAY = 0x8078
  GL_TEXTURE_2D = 0x0DE1
  GL_TEXTURE_WRAP_S = 0x2802
  GL_TEXTURE_WRAP_T = 0x2803
  GL_REPEAT = 0x2901
  GL_TEXTURE_MIN_FILTER = 0x2801
  GL_LINEAR = 0x2601
  GL_TEXTURE_MAG_FILTER = 0x2800
  GL_RGBA = 0x1908
  GL_BGRA = 0x80E1
  GL_UNSIGNED_BYTE = 0x1401
  GL_STENCIL_BUFFER_BIT = 0x00000400
  GL_TRIANGLE_FAN = 0x0006

  ffi_lib 'GL'
  attach_function :glGetIntegerv, [ :uint, :pointer ], :void
  attach_function :glEnableClientState, [ :uint ], :void
  attach_function :glDisableClientState, [ :uint ], :void
  attach_function :glMatrixMode, [ :uint ], :void
  attach_function :glLoadIdentity, [  ], :void
  attach_function :glEnable, [:uint], :void
  attach_function :glDisable, [:uint], :void
  attach_function :glCullFace, [:uint], :void
  attach_function :glFrontFace, [:uint], :void
  attach_function :glDepthMask, [:uint], :void
  attach_function :glDepthFunc, [:uint], :void
  attach_function :glDepthRange, [:double, :double], :void
  attach_function :glClearDepth, [:double], :void
  attach_function :glClearColor, [:float, :float, :float, :float], :void
  attach_function :glClear, [:uint], :void
  attach_function :glViewport, [:uint]*4, :void
  attach_function :glGetString, [:uint], :pointer
  attach_function :glGenerateMipmap, [:uint], :void
  attach_function :glGenTextures, [ :int, :pointer ], :void
  attach_function :glBindTexture, [ :uint, :uint ], :void
  attach_function :glTexParameteri, [ :uint, :uint, :int ], :void
  attach_function :glTexImage2D, [ :uint, :int, :int, :int, :int, :int, :uint, :uint, :pointer ], :void
  attach_function :glPushMatrix, [  ], :void
  attach_function :glPopMatrix, [  ], :void
  attach_function :glTranslatef, [ :float, :float, :float ], :void
  attach_function :glTexCoordPointer, [ :int, :uint, :int, :pointer ], :void
  attach_function :glVertexPointer, [ :int, :uint, :int, :pointer ], :void
  attach_function :glDrawArrays, [ :uint, :int, :int ], :void
  attach_function :glDeleteTextures, [ :int, :pointer ], :void

  ffi_lib 'GLU'
  attach_function :gluPerspective, [:double]*4, :void
  attach_function :gluLookAt, [ :double, :double, :double, :double, :double, :double, :double, :double, :double ], :void

  def self.setup_perspective(fov, width, height)
    GL.glEnable(GL::GL_DEPTH_TEST)
    clear_color([0.0, 0.0, 0.0, 0.0])

    eyeX  = width / 2.0
    eyeY  = height / 2.0
    ratio = width.to_f / height
    halfFov = (Math::PI * fov) / 360.0
    theTan  = Math.tan(halfFov)
    dist = eyeY / theTan
    nearDist = dist / 10.0
    farDist  = dist * 10.0

    GL.glMatrixMode(GL::GL_PROJECTION)
    GL.glLoadIdentity
    GL.gluPerspective(fov, ratio, nearDist, farDist)

    GL.glMatrixMode(GL::GL_MODELVIEW)
    GL.glLoadIdentity
    GL.gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0, 0, 1, 0)

    GL.glEnableClientState(GL::GL_VERTEX_ARRAY)
    GL.glDisableClientState(GL::GL_NORMAL_ARRAY)
    GL.glDisableClientState(GL::GL_COLOR_ARRAY)
    GL.glDisableClientState(GL::GL_TEXTURE_COORD_ARRAY)
  end

  def self.clear_color(color=nil)
    GL.glClearColor(*color) if color
    GL.glClear(GL::GL_COLOR_BUFFER_BIT | \
               GL::GL_DEPTH_BUFFER_BIT | \
               GL::GL_STENCIL_BUFFER_BIT )
  end

  def self.gfx_info
    ["--------------------------------------------------",
    "OpenGL GFX Info:",
    "  Vendor:      %s" % [GL.glGetString(GL::GL_VENDOR).read_string],
    "  Renderer:    %s" % [GL.glGetString(GL::GL_RENDERER).read_string],
    "  OpenGL:      %s" % [GL.glGetString(GL::GL_VERSION).read_string],
    "  GLSL:        %s" % [GL.glGetString(GL::GL_SHADING_LANGUAGE_VERSION).read_string],
    "--------------------------------------------------"].join("\n")
  end

end
end

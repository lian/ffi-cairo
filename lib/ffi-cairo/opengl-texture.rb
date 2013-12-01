require 'ffi-cairo'

module Cairo
  module_function

  def cairo_opengl_texture_size_ok?(width, height) # :nodoc
    GL.glGetIntegerv(GL::GL_MAX_TEXTURE_SIZE, ID_CACHE.put_uint(0, 0))
    max_size = ID_CACHE.read_uint
    return true if (width < max_size) && (height < max_size)

    GL.glGetTexLevelParameteriv(GL::GL_PROXY_TEXTURE_2D, 0, GL::GL_TEXTURE_WIDTH, ID_CACHE.put_uint(0, 0))
    width = ID_CACHE.read_uint
    return true if width > 0

    p ['TEXTURE TOO LARGE for OpenGL!', width, height]
    false
  end


  # un-optimized cairo_opengl_texture.
  # cairo context -> callback -> opengl texture and cleanup -> texture id
  #
  #  cairo_opengl_texture(256, 256){|cr,w,h,c|
  #    Cairo.cairo_move_to(cr, w/10, h/2);
  #    Cairo.cairo_set_font_size(cr, 10);
  #
  #    Cairo.cairo_select_font_face(cr, "sans",
  #      Cairo::CAIRO_FONT_SLANT_NORMAL,
  #      Cairo::CAIRO_FONT_WEIGHT_NORMAL)
  #
  #    Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
  #    Cairo.cairo_show_text(cr, `uptime`.chomp);
  #  }
  #
  def cairo_opengl_texture(width, height, &block)
    return 0 unless cairo_opengl_texture_size_ok?(width, height)

    surface = Cairo.cairo_image_surface_create(
                Cairo::CAIRO_FORMAT_ARGB32, width, height)
    buf = Cairo.cairo_image_surface_get_data(surface)

    cr = Cairo.cairo_create(surface)
    return nil if Cairo.cairo_surface_status(surface) != 0
    return nil if Cairo.cairo_status(cr) != 0

    cr_h = Cairo::ContextHelper.new(cr)
    block.call(cr, width, height, cr_h)

    GL.glGenTextures(1, ID_CACHE.put_uint(0, 0))
    tex_id = ID_CACHE.read_uint

    GL.glEnable(GL::GL_TEXTURE_2D)
      GL.glBindTexture(GL::GL_TEXTURE_2D, tex_id)
      GL.glTexParameteri(GL::GL_TEXTURE_2D, GL::GL_TEXTURE_WRAP_S, GL::GL_REPEAT)
      GL.glTexParameteri(GL::GL_TEXTURE_2D, GL::GL_TEXTURE_WRAP_T, GL::GL_REPEAT)
      GL.glTexParameteri(GL::GL_TEXTURE_2D, GL::GL_TEXTURE_MIN_FILTER, GL::GL_LINEAR)
      GL.glTexParameteri(GL::GL_TEXTURE_2D, GL::GL_TEXTURE_MAG_FILTER, GL::GL_LINEAR)
      #GL.glTexParameteri(GL::GL_TEXTURE_2D, GL::GL_TEXTURE_MAG_FILTER, GL::GL_LINEAR_MIPMAP_LINEAR)
      #GL.glTexEnvf(GL::GL_TEXTURE_ENV, GL::GL_TEXTURE_ENV_MODE, GL::GL_DECAL)
      GL.glTexImage2D(GL::GL_TEXTURE_2D, 0, GL::GL_RGBA, width, height, 0, GL::GL_BGRA,
        GL::GL_UNSIGNED_BYTE, buf)
      #GL.glGenerateMipmap(GL::GL_TEXTURE_2D)
    GL.glBindTexture(GL::GL_TEXTURE_2D, 0)
    GL.glDisable(GL::GL_TEXTURE_2D)


    Cairo.cairo_surface_destroy(surface)
    Cairo.cairo_destroy(cr)
    return tex_id
  end


  # un-optimized opengl cairo surface texture.
  class OpenGL_Texture
    attr_reader :width, :height

    def initialize(width, height, &blk)
      @width, @height = width, height

      _w, _h = width.to_f, height.to_f
      @verts      = FFI::MemoryPointer.new(:float, 8).put_array_of_float(0, [0.0, _h, _w, _h, _w, 0.0, 0.0, 0.0]) # flipped
      @tex_coords = FFI::MemoryPointer.new(:float, 8).put_array_of_float(0, [0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0])

      @cb = blk
      create_texture(@width, @height, &blk)
    end

    def recompile(w=nil, h=nil, &blk)
      create_texture(w||@width, h||@height, &(blk || @cb))
    end
    alias :render :recompile

    def clear!
      GL.glDeleteTextures(1, Cairo::ID_CACHE.put_uint(0, @tex_id)) if @tex_id
    end

    def create_texture(w,h, &blk)
      clear!; @tex_id = Cairo.cairo_opengl_texture(w, h, &blk)
    end

    def draw_at(x,y); draw(@width, @height, x, y); end

    def draw(w=nil, h=nil, x=nil, y=nil) # old opengl api
      return unless @tex_id
      @verts.put_array_of_float(0, [0.0, h, w, h, w, 0.0, 0.0, 0.0]) if w && h
      GL.glTranslatef(x, y, 0.0) if x && y
      draw_texture_verts(@tex_id, @verts, @tex_coords)
    end

    def draw_texture_verts(texture_id, verts, texture_coords) # old opengl api
      GL.glEnable(GL::GL_TEXTURE_2D)
      GL.glBindTexture(GL::GL_TEXTURE_2D, texture_id)
        GL.glEnableClientState(GL::GL_TEXTURE_COORD_ARRAY)
        GL.glTexCoordPointer(2, GL::GL_FLOAT, 0, texture_coords)
        GL.glEnableClientState(GL::GL_VERTEX_ARRAY)
        GL.glVertexPointer(2, GL::GL_FLOAT, 0, verts)
        GL.glDrawArrays(GL::GL_TRIANGLE_FAN, 0, 4)
      GL.glDisableClientState(GL::GL_TEXTURE_COORD_ARRAY)
      GL.glDisable(GL::GL_TEXTURE_2D)
    end
  end

  class OpenGL_Surface
    attr_accessor :callback
    def initialize(width, height)
      @texture = OpenGL_Texture.new(width, height){|cr,w,h,c|
        @callback.call(cr,w,h,c) if @callback
      }
    end

    def draw(cairo_parent_ctx=nil, x=0, y=0)
      render
      redraw(cairo_parent_ctx, x, y)
    end

    def surface; @texture; end
    def render; @texture.recompile; end
    def redraw(_=nil, x=0, y=0); @texture.draw_at(x, y); end
    def destroy; @texture.clear!; end
  end

end

require 'ffi' if Kernel.methods.include?(:require)

module Cairo
  extend FFI::Library
  ffi_lib ['cairo', '/usr/lib/libcairo.so']

  # typedef enum _cairo_format {
    CAIRO_FORMAT_INVALID   = -1
    CAIRO_FORMAT_ARGB32    = 0
    CAIRO_FORMAT_RGB24     = 1
    CAIRO_FORMAT_A8        = 2
    CAIRO_FORMAT_A1        = 3
    CAIRO_FORMAT_RGB16_565 = 4
  # } cairo_format_t;

  # typedef enum _cairo_font_slant {
    CAIRO_FONT_SLANT_NORMAL  = 0
    CAIRO_FONT_SLANT_ITALIC  = 1
    CAIRO_FONT_SLANT_OBLIQUE = 2
  # } cairo_font_slant_t;

  # typedef enum _cairo_font_weight {
    CAIRO_FONT_WEIGHT_NORMAL = 0
    CAIRO_FONT_WEIGHT_BOLD   = 1
  # } cairo_font_weight_t;

  # void cairo_destroy (cairo_t *cr);
  attach_function :cairo_destroy, [:pointer], :void

  # void cairo_surface_destroy (cairo_surface_t *surface);
  attach_function :cairo_surface_destroy, [:pointer], :void

  # cairo_surface_t * cairo_image_surface_create(cairo_format_t format, int width, int height);
  attach_function :cairo_image_surface_create, [:int, :int, :int], :pointer

  # cairo_surface_t * cairo_pdf_surface_create (const char *filename, double width_in_points, double height_in_points);
  attach_function :cairo_pdf_surface_create, [:string, :double, :double], :pointer

  # cairo_surface_t * cairo_xlib_surface_create (Display *dpy, Drawable drawable, Visual *visual, int width, int height);
  attach_function :cairo_xlib_surface_create, [:pointer, :uint, :pointer, :uint, :uint], :pointer

  # void cairo_show_page (cairo_t *cr);
  attach_function :cairo_show_page, [:pointer], :void

  # cairo_surface_t * cairo_svg_surface_create (const char*filename, double width_in_points, double height_in_points);
  attach_function :cairo_svg_surface_create, [:string, :double, :double], :pointer


  # cairo_t * cairo_create (cairo_surface_t *target);
  attach_function :cairo_create, [:pointer], :pointer

  # void cairo_set_source_rgb (cairo_t *cr, double red, double green, double blue);
  attach_function :cairo_set_source_rgb, [:pointer, :double, :double, :double], :void
  attach_function :cairo_set_source_rgba, [:pointer, :double, :double, :double, :double], :void

  # void cairo_select_font_face(cairo_t *cr, const char *family, cairo_font_slant_t slant, cairo_font_weight_t weight);
  attach_function :cairo_select_font_face, [:pointer, :string, :int, :int], :void

  # void cairo_set_font_size (cairo_t *cr, double size);
  attach_function :cairo_set_font_size, [:pointer, :double], :void

  # void cairo_move_to (cairo_t *cr, double x, double y);
  attach_function :cairo_move_to, [:pointer, :double, :double], :void

  attach_function :cairo_rotate, [:pointer, :double], :void

  # void cairo_rel_move_to (cairo_t *cr, double dx, double dy);
  attach_function :cairo_rel_move_to, [:pointer, :double, :double], :void

  # void cairo_show_text (cairo_t *cr, const char *utf8);
  attach_function :cairo_show_text, [:pointer, :string], :void

  if (FFI::Enum rescue false)
    # typedef enum cairo_operator_t {
    Operator = FFI::Enum.new([
      :CAIRO_OPERATOR_CLEAR, :CAIRO_OPERATOR_SOURCE, :CAIRO_OPERATOR_OVER, :CAIRO_OPERATOR_IN, :CAIRO_OPERATOR_OUT,
      :CAIRO_OPERATOR_ATOP, :CAIRO_OPERATOR_DEST, :CAIRO_OPERATOR_DEST_OVER, :CAIRO_OPERATOR_DEST_IN, :CAIRO_OPERATOR_DEST_OUT,
      :CAIRO_OPERATOR_DEST_ATOP, :CAIRO_OPERATOR_XOR, :CAIRO_OPERATOR_ADD, :CAIRO_OPERATOR_SATURATE, :CAIRO_OPERATOR_MULTIPLY,
      :CAIRO_OPERATOR_SCREEN, :CAIRO_OPERATOR_OVERLAY, :CAIRO_OPERATOR_DARKEN, :CAIRO_OPERATOR_LIGHTEN, :CAIRO_OPERATOR_COLOR_DODGE,
      :CAIRO_OPERATOR_COLOR_BURN, :CAIRO_OPERATOR_HARD_LIGHT, :CAIRO_OPERATOR_SOFT_LIGHT, :CAIRO_OPERATOR_DIFFERENCE, :CAIRO_OPERATOR_EXCLUSION,
      :CAIRO_OPERATOR_HSL_HUE, :CAIRO_OPERATOR_HSL_SATURATION, :CAIRO_OPERATOR_HSL_COLOR, :CAIRO_OPERATOR_HSL_LUMINOSITY
    ])
    # } cairo_operator_t;

    # void                cairo_set_operator                  (cairo_t *cr, cairo_operator_t op);
    attach_function :cairo_set_operator, [:pointer, Operator], :void
  else # mruby
    attach_function :cairo_set_operator, [:pointer, :uint], :void
  end

  if (FFI::Enum rescue false)
    # typedef enum _cairo_status {
    Status = FFI::Enum.new([
      :SUCCESS, # = 0,
      :NO_MEMORY, :INVALID_RESTORE, :INVALID_POP_GROUP, :NO_CURRENT_POINT,
      :INVALID_MATRIX, :INVALID_STATUS, :NULL_POINTER, :INVALID_STRING,
      :INVALID_PATH_DATA, :READ_ERROR, :WRITE_ERROR, :SURFACE_FINISHED,
      :SURFACE_TYPE_MISMATCH, :PATTERN_TYPE_MISMATCH, :INVALID_CONTENT,
      :INVALID_FORMAT, :INVALID_VISUAL, :FILE_NOT_FOUND, :INVALID_DASH,
      :INVALID_DSC_COMMENT, :INVALID_INDEX, :CLIP_NOT_REPRESENTABLE,
      :TEMP_FILE_ERROR, :INVALID_STRIDE, :FONT_TYPE_MISMATCH,
      :USER_FONT_IMMUTABLE, :USER_FONT_ERROR, :NEGATIVE_COUNT,
      :INVALID_CLUSTERS, :INVALID_SLANT, :INVALID_WEIGHT, :INVALID_SIZE,
      :USER_FONT_NOT_IMPLEMENTED, :DEVICE_TYPE_MISMATCH, :DEVICE_ERROR,
      :LAST_STATUS ])
    # } cairo_status_t;

    # cairo_status_t cairo_surface_write_to_png (cairo_surface_t	*surface, const char *filename);
    attach_function :cairo_surface_write_to_png, [:pointer, :string], Status
  else # mruby
    attach_function :cairo_surface_write_to_png, [:pointer, :string], :uint
  end

  # cairo_surface_t * cairo_image_surface_create_from_png (const char	*filename);
  attach_function :cairo_image_surface_create_from_png, [:string], :pointer


  # typedef enum _cairo_fill_rule {
    CAIRO_FILL_RULE_WINDING  = 0
    CAIRO_FILL_RULE_EVEN_ODD = 1
  # } cairo_fill_rule_t;

  # void cairo_set_fill_rule (cairo_t *cr, cairo_fill_rule_t fill_rule);
  attach_function :cairo_set_fill_rule, [:pointer, :int], :void


  # void cairo_set_line_width (cairo_t *cr, double width);
  attach_function :cairo_set_line_width, [:pointer, :double], :void

  # void cairo_line_to (cairo_t *cr, double x, double y);
  attach_function :cairo_line_to, [:pointer, :double, :double], :void

  # void cairo_rel_line_to (cairo_t *cr, double dx, double dy);
  attach_function :cairo_rel_line_to, [:pointer, :double, :double], :void

  # void cairo_stroke (cairo_t *cr);
  attach_function :cairo_stroke, [:pointer], :void

  # void cairo_arc (cairo_t *cr, double xc, double yc, double radius, double angle1, double angle2);
  attach_function :cairo_arc, [:pointer, *[:double]*5], :void
  attach_function :cairo_arc_negative, [:pointer, *[:double]*5], :void

  # void cairo_clip (cairo_t *cr);
  attach_function :cairo_clip, [:pointer], :void

  # void cairo_new_path (cairo_t *cr);
  attach_function :cairo_new_path, [:pointer], :void

  # void cairo_close_path (cairo_t *cr);
  attach_function :cairo_close_path, [:pointer], :void

  # void cairo_fill_preserve (cairo_t *cr);
  attach_function :cairo_fill_preserve, [:pointer], :void

  # int cairo_image_surface_get_width (cairo_surface_t *surface);
  attach_function :cairo_image_surface_get_width, [:pointer], :int

  # int cairo_image_surface_get_height (cairo_surface_t *surface);
  attach_function :cairo_image_surface_get_height, [:pointer], :int

  # void cairo_scale (cairo_t *cr, double sx, double sy);
  attach_function :cairo_scale, [:pointer, :double, :double], :void

  # void cairo_set_source_surface (*cr, *surface, double x, double y);
  attach_function :cairo_set_source_surface, [:pointer, :pointer, :double, :double], :void

  # void cairo_set_dash (cairo_t *cr, const double *dashes, int num_dashes, double offset); 
  attach_function :cairo_set_dash, [:pointer, :pointer, :int, :double], :void


  # void cairo_stroke_preserve (cairo_t *cr);
  attach_function :cairo_stroke_preserve, [:pointer], :void

  # void cairo_rel_curve_to (cairo_t *cr, double x1, double y1, double x2, double y2, double x3, double y3);
  attach_function :cairo_curve_to, [:pointer, *[:double]*6], :void

  # void cairo_rel_curve_to (cairo_t *cr, double dx1, double dy1, double dx2, double dy2, double dx3, double dy3);
  attach_function :cairo_rel_curve_to, [:pointer, *[:double]*6], :void

  # void cairo_rectangle (cairo_t *cr, double x, double y, double width, double height);
  attach_function :cairo_rectangle, [:pointer, *[:double]*4], :void

  # void cairo_fill (cairo_t *cr);
  attach_function :cairo_fill, [:pointer], :void


  attach_function :cairo_ft_font_face_create_for_ft_face, [:pointer, :int], :pointer
  attach_function :cairo_font_face_destroy, [:pointer], :void
  attach_function :cairo_set_font_face, [:pointer, :pointer], :void
  attach_function :cairo_set_font_size, [:pointer, :double], :void

  # void cairo_get_font_matrix(cairo_t *cr, cairo_matrix_t *matrix);
  attach_function :cairo_get_font_matrix, [:pointer, :pointer], :void
  # void cairo_set_font_matrix(cairo_t *cr, cairo_matrix_t *matrix);
  attach_function :cairo_set_font_matrix, [:pointer, :pointer], :void

  # cairo_status_t cairo_surface_finish (*surface);
  if (FFI::Enum rescue false)
    attach_function :cairo_surface_finish, [:pointer], Status
  else # mruby
    attach_function :cairo_surface_finish, [:pointer], :uint
  end

  # int cairo_format_stride_for_width (cairo_format_t format, int width);
  attach_function :cairo_format_stride_for_width, [:int, :int], :int

  # void cairo_font_extents (cairo_t *cr, cairo_font_extents_t *extents);
  attach_function :cairo_font_extents, [:pointer, :pointer], :void

  # void cairo_text_extents (cairo_t *cr, const char *utf8, cairo_text_extents_t *extents);
  attach_function :cairo_text_extents, [:pointer, :string, :pointer], :void

  # typedef struct {
  class TextExtents < FFI::Struct
    layout  :x_bearing, :double,
            :y_bearing, :double,
            :width,     :double,
            :height,    :double,
            :x_advance, :double,
            :y_advance, :double
  end
  # } cairo_text_extents_t;

  def self.get_font_matrix(cr)
    mat = FFI::MemoryPointer.new(:double, 6); cairo_get_font_matrix(cr, mat)
    mat.get_array_of_double(0, 6)
  end

  def self.set_font_matrix(cr, mat)
    mat_p = FFI::MemoryPointer.new(:double, 6).put_array_of_double(0, mat)
    cairo_set_font_matrix(cr, mat_p); mat_p.get_array_of_double(0, 6)
  end

  # typedef enum _cairo_antialias {
  CAIRO_ANTIALIAS_DEFAULT  = 0
  CAIRO_ANTIALIAS_NONE     = 1
  CAIRO_ANTIALIAS_GRAY     = 2
  CAIRO_ANTIALIAS_SUBPIXEL = 3
  # } cairo_antialias_t;

  attach_function :cairo_font_options_create, [], :pointer
  attach_function :cairo_font_options_destroy, [:pointer], :void
  attach_function :cairo_font_options_get_antialias, [:pointer], :int
  attach_function :cairo_font_options_set_antialias, [:pointer, :int], :void

  attach_function :cairo_get_font_options, [:pointer, :pointer], :void
  attach_function :cairo_set_font_options, [:pointer, :pointer], :void

  def self.clear_background(cr, red, green, blue)
    cairo_set_operator(cr, Cairo::CAIRO_OPERATOR_OVER)
    cairo_set_source_rgb(cr, red, green, blue)
    cairo_paint(cr)
  end


  # cairo_surface_t *cairo_image_surface_create_for_data(unsigned char *data,
  #   cairo_format_t format, int width, int height, int stride);
  attach_function :cairo_image_surface_create_for_data, [:pointer,
    :int, :int, :int, :int], :pointer

  attach_function :cairo_surface_status, [:pointer], :int
  attach_function :cairo_status, [:pointer], :int
  CAIRO_OPERATOR_OVER = 2

  attach_function :cairo_set_operator, [:pointer, :int], :void
  attach_function :cairo_paint, [:pointer], :void

  ID_CACHE      = FFI::MemoryPointer.new(:uint, 1)

  attach_function :cairo_image_surface_create, [:int,:int,:int], :pointer
  attach_function :cairo_image_surface_get_data, [:pointer], :pointer


  class ContextHelper
    attr_reader :context, :surface

    def initialize(context, surface=nil)
      @context, @surface = context, surface
    end

    def ctx; @context; end

    if (Regexp rescue false)
      ::Cairo.methods.grep(/^cairo_/).each{|m|
        define_method(m.to_s.gsub(/^cairo_/,'').to_sym, proc{|*a| Cairo.send(m, @context, *a) })
      }
    else # mruby
      ::Cairo.methods.each{|m|
        next unless m.to_s[0..5] == 'cairo_'
        define_method(m.to_s[6..-1].to_sym){|*a| p a; Cairo.send(m, @context, *a) }
      }
    end

    def text_extents(text)
      extents = Cairo::TextExtents.new
      Cairo.cairo_text_extents(@context, text, extents)
      values = extents.values
      extents = nil
      Hash[*[:x_bearing, :y_bearing, :width, :height, :x_advance, :y_advance].zip(values).flatten]
    end

    def font_size=(size)
      Cairo.cairo_set_font_size(@context, size)
    end

    def font=(name)
      Cairo.cairo_select_font_face(@context, name,
        Cairo::CAIRO_FONT_SLANT_NORMAL,
        Cairo::CAIRO_FONT_WEIGHT_NORMAL)
    end

    def to_png(filename)
      Cairo.cairo_surface_write_to_png(@surface, filename) if @surface
    end

    def background(r,g,b)
      Cairo.clear_background(@context, r, g, b)
    end

    def background_border(r,g,b,w,h)
      set_source_rgb(r,g,b); move_to(0,0); rectangle(0, 0, w-2, h-2); stroke
    end

    def show_text(text)
      Cairo.cairo_show_text(@context, text)
    end

    def destroy
      Cairo.cairo_destroy(@context) if @context
      Cairo.cairo_surface_destroy(@surface) if @surface
    end

    # maybe switch to pango if this is too slow
    #  * http://stackoverflow.com/questions/10200201/how-to-get-pango-cairo-to-word-wrap-properly
    def text_to_lines(text, max_width)
      words, lines = text.split(" "), [ [] ]
      while next_word = words.shift
        tmp = (lines.last + [next_word]).join(" ")
        # word fits
        if text_extents(tmp)[:width] < max_width
          lines.last << next_word
        # word too long for a single line, force split word
        elsif text_extents(next_word)[:width] > max_width
          chars, next_word = next_word.scan(/./), ''
          loop{
            next_char = chars.shift; break unless next_char
            tmp = (lines.last + [next_word+next_char]).join(' ')
            if text_extents(tmp)[:width] < max_width
              next_word << next_char
            else
              words.unshift(chars.unshift(next_char).join)
              if next_word == ''
                lines << []
              else
                lines.last << next_word
              end
              break
            end
          }
        # word to next line
        else
          lines << [ next_word ]
        end
      end
      lines.delete_if{|i| i.empty? }
      lines.map{|i| i.join(" ") }
    end
  end

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


if $0 == __FILE__
  w,h = 512, 200
  surface = Cairo.cairo_image_surface_create(Cairo::CAIRO_FORMAT_ARGB32, w, h)

  cr = Cairo.cairo_create(surface)

  c = Cairo::ContextHelper.new(cr, surface)

  c.set_source_rgb(0.3, 0.1, 0.1)
  c.rectangle(0, 0, w, h)
  c.fill

  c.set_source_rgb(0.5, 0.5, 0.5)
  c.rectangle(10, 10, w-20, h-20)
  c.fill

  c.set_source_rgb(0.0, 0.5, 0.0)
  c.rectangle(20, 25, 100, 5)
  c.fill

  c.set_source_rgb(1, 1, 1)

  c.font = "Sans"
  c.font_size = 12

  c.move_to(10, 20)
  if (RUBY_VERSION rescue false)
    c.show_text("host: " + 'uname -nmor'.chomp)
  else # mruby
    c.show_text("some text")
  end

  c.font_size = 15.0
  c.move_to(10, 60)
  if (RUBY_VERSION rescue false)
    c.show_text('uptime'.chomp)
  else # mruby
    c.show_text("some other text")
  end

  extents = Cairo::TextExtents.new
  Cairo.cairo_text_extents(cr, "A"*10, extents)
  p extents.values

  c.set_source_rgb(0, 0, 1)
  c.move_to 10, 100
  c.line_to 100, 140
  c.stroke

  c.arc(100, 100, 10, 0, 2 * Math::PI)
  c.stroke

  c.arc(150, 100, 10, 0, 2 * Math::PI)
  c.fill

  c.to_png("image.png")
  c.destroy

  #system("feh image.png")
end

require 'ffi'

module Cairo
  extend FFI::Library
  ffi_lib 'cairo'

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

    ::Cairo.methods.grep(/^cairo_/).each{|m|
      define_method(m.to_s.gsub(/^cairo_/,'').to_sym, proc{|*a| Cairo.send(m, @context, *a) })
    }

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

    def background(r,g,b,w,h)
      set_source_rgb(r,g,b); move_to(0,0); rectangle(0, 0, w, h); fill
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
  end

end


if $0 == __FILE__
  w,h = 512, 100
  surface = Cairo.cairo_image_surface_create(Cairo::CAIRO_FORMAT_ARGB32, w, h)

  cr = Cairo.cairo_create(surface)
  Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
  Cairo.cairo_rectangle(cr, 0, 0, w, h)
  Cairo.cairo_fill(cr)

  #Cairo.cairo_set_source_rgb(cr, 0.5, 0.5, 0.5)
  #Cairo.cairo_rectangle(cr, 10, 10, w-20, h-20)
  #Cairo.cairo_fill(cr)

  Cairo.cairo_set_source_rgb(cr, 0.0, 0.5, 0.0)
  Cairo.cairo_rectangle(cr, 20, 25, 100, 5)
  Cairo.cairo_fill(cr)

  Cairo.cairo_set_source_rgb(cr, 1, 1, 1)

  Cairo.cairo_select_font_face(cr, "Sans", Cairo::CAIRO_FONT_SLANT_NORMAL, Cairo::CAIRO_FONT_WEIGHT_NORMAL)

  Cairo.cairo_set_font_size(cr, 12)
  Cairo.cairo_move_to(cr, 10, 20)
  Cairo.cairo_show_text(cr, "host: " + `uname -nmor`.chomp)

  Cairo.cairo_set_font_size(cr, 15.0)
  Cairo.cairo_move_to(cr, 10, 60)
  Cairo.cairo_show_text(cr, `uptime`.chomp)

  p Cairo.cairo_surface_write_to_png(surface, ARGV[0] || "image.png") # write png.

  Cairo.cairo_destroy(cr)
  Cairo.cairo_surface_destroy(surface)

  #system("feh image.png")
end

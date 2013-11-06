module Cairo
  module Example

    #
    # cairo api examples taken from: http://www.cairographics.org/samples/
    #


    def self.arc(cr)
      xc, yc, radius = 128.0, 128.0, 100.0
      angle1 = 45.0  * (Math::PI/180.0) # angle as radians
      angle2 = 180.0 * (Math::PI/180.0) # angle as radians

      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_arc(cr, xc, yc, radius, angle1, angle2)
      Cairo.cairo_stroke(cr)

      # draw helping lines
      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
      Cairo.cairo_set_line_width(cr, 6.0)

      Cairo.cairo_arc(cr, xc, yc, 10.0, 0, 2*Math::PI)
      Cairo.cairo_fill(cr)

      Cairo.cairo_arc(cr, xc, yc, radius, angle1, angle1)
      Cairo.cairo_line_to(cr, xc, yc)
      Cairo.cairo_arc(cr, xc, yc, radius, angle2, angle2)
      Cairo.cairo_line_to(cr, xc, yc)
      Cairo.cairo_stroke(cr)
    end


    def self.arc_negative(cr)
      xc, yc, radius = 128.0, 128.0, 100.0
      angle1 = 45.0  * (Math::PI/180.0) # angle as radians
      angle2 = 180.0 * (Math::PI/180.0) # angle as radians

      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_arc_negative(cr, xc, yc, radius, angle1, angle2)
      Cairo.cairo_stroke(cr)

      # draw helping lines
      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
      Cairo.cairo_set_line_width(cr, 6.0)

      Cairo.cairo_arc(cr, xc, yc, 10.0, 0, 2*Math::PI)
      Cairo.cairo_fill(cr)

      Cairo.cairo_arc(cr, xc, yc, radius, angle1, angle1)
      Cairo.cairo_line_to(cr, xc, yc)
      Cairo.cairo_arc(cr, xc, yc, radius, angle2, angle2)
      Cairo.cairo_line_to(cr, xc, yc)
      Cairo.cairo_stroke(cr)
    end


    def self.clip(cr)
      Cairo.cairo_arc(cr, 128.0, 128.0, 76.8, 0, 2 * Math::PI)
      Cairo.cairo_clip(cr)

      Cairo.cairo_new_path(cr) # current path is not consumed by cairo_clip
      Cairo.cairo_rectangle(cr, 0, 0, 256, 256)
      Cairo.cairo_fill(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 1, 0)
      Cairo.cairo_move_to(cr, 0, 0)
      Cairo.cairo_line_to(cr, 256, 256)
      Cairo.cairo_move_to(cr, 256, 0)
      Cairo.cairo_line_to(cr, 0, 256)
      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_stroke(cr)
    end


    def self.clip_image(cr, image_path)
      return nil unless File.exists?(image_path)

      Cairo.cairo_arc(cr, 128.0, 128.0, 76.8, 0, 2*Math::PI)
      Cairo.cairo_clip(cr)
      Cairo.cairo_new_path(cr) # path not consumed by cairo_clip

      image = Cairo.cairo_image_surface_create_from_png( image_path )
      w = Cairo.cairo_image_surface_get_width(image)
      h = Cairo.cairo_image_surface_get_height(image)

      Cairo.cairo_scale(cr, 256.0/w, 256.0/h)

      Cairo.cairo_set_source_surface(cr, image, 0, 0)
      Cairo.cairo_paint(cr)

      Cairo.cairo_surface_destroy(image)
    end


    def self.curve_to(cr)
      x, y = 25.6, 128.0
      x1, y1, x2, y2, x3, y3 = 102.4, 230.4, 153.6, 25.6, 230.4, 128.0

      Cairo.cairo_move_to(cr, x, y)
      Cairo.cairo_curve_to(cr, x1, y1, x2, y2, x3, y3)

      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_stroke(cr)

      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
      Cairo.cairo_set_line_width(cr, 6.0)
      Cairo.cairo_move_to(cr,x,y);   Cairo.cairo_line_to(cr,x1,y1)
      Cairo.cairo_move_to(cr,x2,y2); Cairo.cairo_line_to(cr,x3,y3)
      Cairo.cairo_stroke(cr)
    end


    def self.dash(cr)
      dashes_ = [50.0, 10.0, 10.0, 10.0]
      dashes = FFI::MemoryPointer.new(:double, dashes_.size).put_array_of_double(0, dashes_)

      ndash  = dashes.size
      offset = -50.0

      Cairo.cairo_set_dash(cr, dashes, ndash, offset)
      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)

      Cairo.cairo_move_to(cr, 128.0, 25.6)
      Cairo.cairo_line_to(cr, 230.4, 230.4)
      Cairo.cairo_rel_line_to(cr, -102.4, 0.0)
      Cairo.cairo_curve_to(cr, 51.2, 230.4, 51.2, 128.0, 128.0, 128.0)

      Cairo.cairo_stroke(cr)
    end


    def self.fill_and_stroke(cr)
      Cairo.cairo_move_to(cr, 128.0, 25.6)
      Cairo.cairo_line_to(cr, 230.4, 230.4)
      Cairo.cairo_rel_line_to(cr, -102.4, 0.0)
      Cairo.cairo_curve_to(cr, 51.2, 230.4, 51.2, 128.0, 128.0, 128.0)
      Cairo.cairo_close_path(cr)

      Cairo.cairo_move_to(cr, 64.0, 25.6)
      Cairo.cairo_rel_line_to(cr, 51.2, 51.2)
      Cairo.cairo_rel_line_to(cr, -51.2, 51.2)
      Cairo.cairo_rel_line_to(cr, -51.2, -51.2)
      Cairo.cairo_close_path(cr)

      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 1)
      Cairo.cairo_fill_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_stroke(cr)
    end


    def self.file_style(cr)
      Cairo.cairo_set_line_width(cr, 6)

      Cairo.cairo_rectangle(cr, 12, 12, 232, 70)
      Cairo.cairo_new_sub_path(cr); Cairo.cairo_arc(cr, 64, 64, 40, 0, 2*Math::PI)
      Cairo.cairo_new_sub_path(cr); Cairo.cairo_arc_negative(cr, 192, 64, 40, 0, -2*Math::PI)

      Cairo.cairo_set_fill_rule(cr, Cairo::CAIRO_FILL_RULE_EVEN_ODD)
      Cairo.cairo_set_source_rgb(cr, 0, 0.7, 0); Cairo.cairo_fill_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0);   Cairo.cairo_stroke(cr)

      Cairo.cairo_translate(cr, 0, 128)
      Cairo.cairo_rectangle(cr, 12, 12, 232, 70)
      Cairo.cairo_new_sub_path(cr); Cairo.cairo_arc(cr, 64, 64, 40, 0, 2*Math::PI)
      Cairo.cairo_new_sub_path(cr); Cairo.cairo_arc_negative(cr, 192, 64, 40, 0, -2*Math::PI)

      Cairo.cairo_set_fill_rule(cr, Cairo::CAIRO_FILL_RULE_WINDING)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0.9); Cairo.cairo_fill_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0);   Cairo.cairo_stroke(cr)
    end


    def self.gradient(cr)
      pat = Cairo.cairo_pattern_create_linear(0.0, 0.0,  0.0, 256.0)
      Cairo.cairo_pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 1)
      Cairo.cairo_pattern_add_color_stop_rgba(pat, 0, 1, 1, 1, 1)
      Cairo.cairo_rectangle(cr, 0, 0, 256, 256)
      Cairo.cairo_set_source(cr, pat)
      Cairo.cairo_fill(cr)
      Cairo.cairo_pattern_destroy(pat)

      pat = Cairo.cairo_pattern_create_radial(115.2, 102.4, 25.6, 102.4,  102.4, 128.0)
      Cairo.cairo_pattern_add_color_stop_rgba(pat, 0, 1, 1, 1, 1)
      Cairo.cairo_pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 1)
      Cairo.cairo_set_source(cr, pat)
      Cairo.cairo_arc(cr, 128.0, 128.0, 76.8, 0, 2 * Math::PI)
      Cairo.cairo_fill(cr)
      Cairo.cairo_pattern_destroy(pat)
    end


    def self.image(cr, image_path)
      return nil unless File.exists?(image_path)

      image = Cairo.cairo_image_surface_create_from_png(image_path)
      w = Cairo.cairo_image_surface_get_width(image)
      h = Cairo.cairo_image_surface_get_height(image)

      Cairo.cairo_translate(cr, 128.0, 128.0)
      Cairo.cairo_rotate(cr, 45* Math::PI/180)
      Cairo.cairo_scale(cr, 256.0/w, 256.0/h)
      Cairo.cairo_translate(cr, -0.5*w, -0.5*h)

      Cairo.cairo_set_source_surface(cr, image, 0, 0)
      Cairo.cairo_paint(cr)
      Cairo.cairo_surface_destroy(image)
    end


    def self.image_pattern(cr, image_path)
      return nil unless File.exists?(image_path)

      image = Cairo.cairo_image_surface_create_from_png("data/romedalen.png")
      w = Cairo.cairo_image_surface_get_width(image)
      h = Cairo.cairo_image_surface_get_height(image)

      pattern = Cairo.cairo_pattern_create_for_surface(image)
      Cairo.cairo_pattern_set_extend(pattern, Cairo::CAIRO_EXTEND_REPEAT)

      Cairo.cairo_translate(cr, 128.0, 128.0)
      Cairo.cairo_rotate(cr, M_PI / 4)
      Cairo.cairo_scale(cr, 1 / sqrt(2), 1 / sqrt(2))
      Cairo.cairo_translate(cr, -128.0, -128.0)

      mat = FFI::MemoryPointer.new(:double, 6)
      Cairo.cairo_matrix_init_scale(mat, w/256.0 * 5.0, h/256.0 * 5.0)
      Cairo.cairo_pattern_set_matrix(pattern, mat)

      Cairo.cairo_set_source(cr, pattern)

      Cairo.cairo_rectangle(cr, 0, 0, 256.0, 256.0)
      Cairo.cairo_fill(cr)

      Cairo.cairo_pattern_destroy(pattern)
      Cairo.cairo_surface_destroy(image)
    end

    def self.multi_segment_caps(cr)
      Cairo.cairo_move_to(cr, 50.0, 75.0)
      Cairo.cairo_line_to(cr, 200.0, 75.0)

      Cairo.cairo_move_to(cr, 50.0, 125.0)
      Cairo.cairo_line_to(cr, 200.0, 125.0)

      Cairo.cairo_move_to(cr, 50.0, 175.0)
      Cairo.cairo_line_to(cr, 200.0, 175.0)

      Cairo.cairo_set_line_width(cr, 30.0)
      Cairo.cairo_set_line_cap(cr, Cairo::CAIRO_LINE_CAP_ROUND)
      Cairo.cairo_stroke(cr)
    end


    def self.rounded_rectangle(cr)
      # a custom shape that could be wrapped in a function
      x, y = 25.6, 25.6
      width, height = 204.8, 204.8
      aspect, corner_radius = 1.0, height / 10.0

      radius = corner_radius / aspect
      degrees = Math::PI / 180.0

      Cairo.cairo_new_sub_path(cr)
      Cairo.cairo_arc(cr, x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees)
      Cairo.cairo_arc(cr, x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees)
      Cairo.cairo_arc(cr, x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees)
      Cairo.cairo_arc(cr, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
      Cairo.cairo_close_path(cr)

      Cairo.cairo_set_source_rgb(cr, 0.5, 0.5, 1)
      Cairo.cairo_fill_preserve(cr)
      Cairo.cairo_set_source_rgba(cr, 0.5, 0, 0, 0.5)
      Cairo.cairo_set_line_width(cr, 10.0)
      Cairo.cairo_stroke(cr)
    end


    def self.set_line_cap(cr)
      Cairo.cairo_set_line_width(cr, 30.0)
      Cairo.cairo_set_line_cap(cr, Cairo::CAIRO_LINE_CAP_BUTT) # default
      Cairo.cairo_move_to(cr, 64.0, 50.0);   Cairo.cairo_line_to(cr, 64.0, 200.0)
      Cairo.cairo_stroke(cr)
      Cairo.cairo_set_line_cap(cr, Cairo::CAIRO_LINE_CAP_ROUND)
      Cairo.cairo_move_to(cr, 128.0, 50.0);  Cairo.cairo_line_to(cr, 128.0, 200.0)
      Cairo.cairo_stroke(cr)
      Cairo.cairo_set_line_cap(cr, Cairo::CAIRO_LINE_CAP_SQUARE)
      Cairo.cairo_move_to(cr, 192.0, 50.0);  Cairo.cairo_line_to(cr, 192.0, 200.0)
      Cairo.cairo_stroke(cr)

      # draw helping lines
      Cairo.cairo_set_source_rgb(cr, 1, 0.2, 0.2)
      Cairo.cairo_set_line_width(cr, 2.56)
      Cairo.cairo_move_to(cr, 64.0, 50.0);   Cairo.cairo_line_to(cr, 64.0, 200.0)
      Cairo.cairo_move_to(cr, 128.0, 50.0);  Cairo.cairo_line_to(cr, 128.0, 200.0)
      Cairo.cairo_move_to(cr, 192.0, 50.0);  Cairo.cairo_line_to(cr, 192.0, 200.0)
      Cairo.cairo_stroke(cr)
    end


    def self.set_line_join(cr)
      Cairo.cairo_set_line_width(cr, 40.96)
      Cairo.cairo_move_to(cr, 76.8, 84.48)
      Cairo.cairo_rel_line_to(cr, 51.2, -51.2)
      Cairo.cairo_rel_line_to(cr, 51.2, 51.2)
      Cairo.cairo_set_line_join(cr, Cairo::CAIRO_LINE_JOIN_MITER) # default
      Cairo.cairo_stroke(cr)

      Cairo.cairo_move_to(cr, 76.8, 161.28)
      Cairo.cairo_rel_line_to(cr, 51.2, -51.2)
      Cairo.cairo_rel_line_to(cr, 51.2, 51.2)
      Cairo.cairo_set_line_join(cr, Cairo::CAIRO_LINE_JOIN_BEVEL)
      Cairo.cairo_stroke(cr)

      Cairo.cairo_move_to(cr, 76.8, 238.08)
      Cairo.cairo_rel_line_to(cr, 51.2, -51.2)
      Cairo.cairo_rel_line_to(cr, 51.2, 51.2)
      Cairo.cairo_set_line_join(cr, Cairo::CAIRO_LINE_JOIN_ROUND)
      Cairo.cairo_stroke(cr)
    end


    def self.text(cr)
      Cairo.cairo_select_font_face(cr, "Sans",
                                   Cairo::CAIRO_FONT_SLANT_NORMAL,
                                   Cairo::CAIRO_FONT_WEIGHT_BOLD)
      Cairo.cairo_set_font_size(cr, 90.0)

      Cairo.cairo_move_to(cr, 10.0, 135.0)
      Cairo.cairo_show_text(cr, "Hello")

      Cairo.cairo_move_to(cr, 70.0, 165.0)
      Cairo.cairo_text_path(cr, "void")
      Cairo.cairo_set_source_rgb(cr, 0.5, 0.5, 1)
      Cairo.cairo_fill_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_set_line_width(cr, 2.56)
      Cairo.cairo_stroke(cr)

      # draw helping lines
      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
      Cairo.cairo_arc(cr, 10.0, 135.0, 5.12, 0, 2*Math::PI)
      Cairo.cairo_close_path(cr)
      Cairo.cairo_arc(cr, 70.0, 165.0, 5.12, 0, 2*Math::PI)
      Cairo.cairo_fill(cr)
    end


=begin
    def self.text_align_center(cr)
      #cairo_text_extents_t extents;
      utf8 = "cairo";

      Cairo.cairo_select_font_face(cr, "Sans",
                                   Cairo::CAIRO_FONT_SLANT_NORMAL,
                                   Cairo::CAIRO_FONT_WEIGHT_NORMAL)

      Cairo.cairo_set_font_size(cr, 52.0)
      Cairo.cairo_text_extents(cr, utf8, extents_p)

      #x = 128.0 - extents_p[:width] / 2   + extents_p[:x_bearing]
      #y = 128.0 - extents_p[:height] / 2  + extents_p[:y_bearing]

      Cairo.cairo_move_to(cr, x, y)
      Cairo.cairo_show_text(cr, utf8)

      # draw helping lines
      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
      Cairo.cairo_set_line_width(cr, 6.0)
      Cairo.cairo_arc(cr, x, y, 10.0, 0, 2*Math::PI)
      Cairo.cairo_fill(cr)
      Cairo.cairo_move_to(cr, 128.0, 0)
      Cairo.cairo_rel_line_to(cr, 0, 256)
      Cairo.cairo_move_to(cr, 0, 128.0)
      Cairo.cairo_rel_line_to(cr, 256, 0)
      Cairo.cairo_stroke(cr)
    end


    def self.text_extents(cr)
      # cairo_text_extents_t extents;
      utf8 = "cairo"
      x, y = 25.0, 150.0

      Cairo.cairo_select_font_face(cr, "Sans",
                                   CAIRO_FONT_SLANT_NORMAL,
                                   CAIRO_FONT_WEIGHT_NORMAL)

      Cairo.cairo_set_font_size(cr, 100.0)
      Cairo.cairo_text_extents(cr, utf8, extents_p)

      Cairo.cairo_move_to(cr, x,y)
      Cairo.cairo_show_text(cr, utf8)

      # draw helping lines
      Cairo.cairo_set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
      Cairo.cairo_set_line_width(cr, 6.0)
      Cairo.cairo_arc(cr, x, y, 10.0, 0, 2*Math::PI)
      Cairo.cairo_fill(cr)
      Cairo.cairo_move_to(cr, x, y)
      Cairo.cairo_rel_line_to(cr, 0, -extents[:height])
      Cairo.cairo_rel_line_to(cr, extents_p[:width], 0)
      Cairo.cairo_rel_line_to(cr, extents_p[:x_bearing], -extents_p[:y_bearing])
      Cairo.cairo_stroke(cr)
    end
=end


    #
    # http://cairographics.org/cookbook/roundedrectangles/
    #
    # ..

  end # Example
end

module Cairo
  module Example
    def self.solid_colors(cr)
      Cairo.cairo_set_source_rgb(cr, 0.5, 0.5, 1)
      Cairo.cairo_rectangle(cr, 20, 20, 100, 100)
      Cairo.cairo_fill(cr)

      Cairo.cairo_set_source_rgb(cr, 0.6, 0.6, 0.6)
      Cairo.cairo_rectangle(cr, 150, 20, 100, 100)
      Cairo.cairo_fill(cr)
     
      Cairo.cairo_set_source_rgb(cr, 0, 0.3, 0)
      Cairo.cairo_rectangle(cr, 20, 140, 100, 100)
      Cairo.cairo_fill(cr)

      Cairo.cairo_set_source_rgb(cr, 1, 0, 0.5)
      Cairo.cairo_rectangle(cr, 150, 140, 100, 100)
      Cairo.cairo_fill(cr)
    end

    def self.fill_and_stroke_2(cr, width, height)
      Cairo.cairo_set_line_width(cr, 9)

      Cairo.cairo_set_source_rgb(cr, 0.69, 0.19, 0)
      Cairo.cairo_arc(cr, width/2, height/2, 
          (width < height ? width : height) / 2 - 10, 0, 2 * Math::PI)
      Cairo.cairo_stroke_preserve(cr)

      Cairo.cairo_set_source_rgb(cr, 0.3, 0.4, 0.6)
      Cairo.cairo_fill(cr)
    end

    def self.relative_lines(cr)
      Cairo.cairo_line_to(cr, 0.5, 0.375)
      Cairo.cairo_rel_line_to(cr, 0.25, -0.125)
    end

    def self.basic_shapes(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_set_line_width(cr, 1)

      Cairo.cairo_rectangle(cr, 20, 20, 120, 80) # rectangle
      Cairo.cairo_rectangle(cr, 180, 20, 80, 80) # square
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr)

      # circle
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_arc(cr, 330, 60, 40, 0, 2*Math::PI)
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr)

      # arc
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_arc(cr, 90, 160, 40, M_PI/4, Math::PI)
      Cairo.cairo_close_path(cr)
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr);

      # ellipse
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_translate(cr, 220, 180)
      Cairo.cairo_scale(cr, 1, 0.7)
      Cairo.cairo_arc(cr, 0, 0, 50, 0, 2*Math::PI);
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr)
    end

    def self.more_shapes(cr)
      Cairo.cairo_set_source_rgb(cr, 0, 0, 0);
      Cairo.cairo_set_line_width(cr, 1);

      [
        [0, 85], [75, 75], [100, 10], [125, 75], [200, 85],
        [150, 125], [160, 190], [100, 150], [40, 190],[50, 125], [0, 85] 
      ].each{|pt|
        Cairo.cairo_line_to(cr, pt[0], pt[1])
      }

      Cairo.cairo_close_path(cr)
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr)


      Cairo.cairo_move_to(cr, 240, 40)
      Cairo.cairo_line_to(cr, 240, 160)
      Cairo.cairo_line_to(cr, 350, 160)
      Cairo.cairo_close_path(cr)

      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr)

      Cairo.cairo_move_to(cr, 380, 40)
      Cairo.cairo_line_to(cr, 380, 160)
      Cairo.cairo_line_to(cr, 450, 160)
      Cairo.cairo_curve_to(cr, 440, 155, 380, 145, 380, 40)

      Cairo.cairo_set_source_rgb(cr, 0, 0, 0)
      Cairo.cairo_stroke_preserve(cr)
      Cairo.cairo_set_source_rgb(cr, 1, 1, 1)
      Cairo.cairo_fill(cr)
    end
  end # Example
end # Cairo

require 'ffi'

module Cairo
  module Font

    module FreeType
      extend FFI::Library
      ffi_lib ['freetype', '/opt/local/lib/libfreetype.dylib']

      attach_function :FT_Init_FreeType,   [:pointer], :int
      attach_function :FT_New_Face,        [:pointer, :string, :int, :pointer], :int
      attach_function :FT_Done_Face,       [:pointer], :int
      attach_function :FT_Done_FreeType,   [:pointer], :int

      def self.default_face(path=nil)
        @default_face ||= load_face(path)
      end

      def self.load_face(path=nil); FontFace.new(path); end

      #Cairo.cairo_set_font_face(cr, font.cairo_face)
      #Cairo.cairo_set_font_size(cr, fh)

      @loaded_fonts = {}
      def self.load_font(name, path, font_height=nil); @loaded_fonts[name] ||= load_face(path); end
      def self.[](name); @loaded_fonts[name].cairo_face rescue nil; end
   

      class FontFace
        class CairoError < StandardError; end
        class FreetypeError < StandardError; end

        def initialize(path)
          raise "File not Found: #{path}" unless File.exists?(path)
          @file    = File.expand_path(path)
          @ft_lib  = FFI::MemoryPointer.new(:pointer, 1)
          @ft_face = FFI::MemoryPointer.new(:pointer, 1)
          raise FreeTypeError, 'FT_Init_FreeType falied' if FreeType.FT_Init_FreeType(@ft_lib) != 0
          raise FreeTypeError, 'FT_New_Face failed (font loading)' if \
            FreeType.FT_New_Face(@ft_lib.read_pointer, @file, 0,  @ft_face) != 0
        end

        def cairo_face
          @font_face ||= Cairo.cairo_ft_font_face_create_for_ft_face(freetype_face, 0)
        end

        def freetype_face; @ft_face.read_pointer; end

        def free
          free_cairo if @font_face
          FreeType.FT_Done_Face(@ft_face.read_pointer)
          FreeType.FT_Done_FreeType(@ft_lib.read_pointer)
        end

        def free_cairo
          Cairo.cairo_font_face_destroy(@font_face) if @font_face
        end
      end

    end

  end
end

require 'ffi'

if defined?(Cairo)
  module Cairo
    def self.draw_freeimage_surface(cairo_helper, filename, x=0, y=0, &blk)
      if File.exists?(filename)
        Cairo::FreeImage::ImageFile.new(filename) do |freeimage|
        #freeimage = Cairo::FreeImage::ImageFile.new(filename)
        #if freeimage.loaded
          stride = Cairo.cairo_format_stride_for_width(Cairo::CAIRO_FORMAT_ARGB32, freeimage.width)
          image = Cairo.cairo_image_surface_create_for_data(freeimage.data, Cairo::CAIRO_FORMAT_ARGB32,
                                                            freeimage.width, freeimage.height, stride)
          if blk
            blk.call(cairo_helper, image, freeimage.width, freeimage.height)
          else
            #scale_factor = 1.5
            #c.scale(scale_factor, scale_factor)
            c.set_source_surface(image, x, y)
            c.paint
            #c.scale(1/scale_factor, 1/scale_factor)
          end
          Cairo.cairo_surface_destroy(image)
        end
        #freeimage.destroy
      end
    end
  end
end

module Cairo
module FreeImage
  extend FFI::Library
  ffi_lib ['libfreeimage','/opt/local/lib/libfreeimage.dylib']

  attach_function :FreeImage_Initialise, [], :int
  attach_function :FreeImage_DeInitialise, [], :int
  send(:FreeImage_Initialise)

  attach_function :FreeImage_GetFileType, [:string, :int], :int
  attach_function :FreeImage_GetFIFFromFilename, [:string], :int
  attach_function :FreeImage_FIFSupportsReading, [:int], :int
  attach_function :FreeImage_Load, [:int, :string, :int], :pointer
  attach_function :FreeImage_Unload, [:pointer], :int

  attach_function :FreeImage_GetWidth,  [:pointer], :int
  attach_function :FreeImage_GetHeight, [:pointer], :int
  attach_function :FreeImage_GetBPP,    [:pointer], :int
  attach_function :FreeImage_GetColorType, [:pointer], :int

  attach_function :FreeImage_ConvertTo24Bits, [:pointer], :pointer
  attach_function :FreeImage_ConvertTo32Bits, [:pointer], :pointer
  attach_function :FreeImage_ConvertToRawBits, [:pointer, :pointer, :int, :uint, :uint, :uint, :uint, :int], :void

  FIF_UNKNOWN  = -1
  FIC_PALETTE  = 3
  FI_RGBA_RED_MASK    = 0xFF000000
  FI_RGBA_GREEN_MASK  = 0x00FF0000
  FI_RGBA_BLUE_MASK   = 0x0000FF00

  IMAGE_GRAYSCALE   = 0
  IMAGE_COLOR       = 1
  IMAGE_COLOR_ALPHA = 2
  IMAGE_UNDEFINED   = 3

  class ImageFile
    attr_reader :filename, :width, :height, :bits_per_pixel, :bytes_per_pixel, :data, :loaded
    def initialize(filename, &blk)
      read_image_into_pixels(filename, &blk)
    end

    def read_image_into_pixels(filename, &blk)
      @filename = filename
      fif = FreeImage.FreeImage_GetFileType(filename, 0)
      fif = FreeImage.FreeImage_GetFIFFromFilename(filename) if fif == FreeImage::FIF_UNKNOWN
      if (fif != FreeImage::FIF_UNKNOWN) && FreeImage.FreeImage_FIFSupportsReading(fif)
        bmp_p   = FreeImage.FreeImage_Load(fif, filename, 0)
        @loaded = bmp_p.address != 0
      end
      if @loaded
        @width          = FreeImage.FreeImage_GetWidth(bmp_p)
        @height         = FreeImage.FreeImage_GetHeight(bmp_p)
        @bits_per_pixel = FreeImage.FreeImage_GetBPP(bmp_p)

        unless @bits_per_pixel == 32
          bits_32 = FreeImage.FreeImage_ConvertTo32Bits(bmp_p)
          FreeImage.FreeImage_Unload(bmp_p)
          bmp_p = bits_32; @bits_per_pixel = FreeImage.FreeImage_GetBPP(bmp_p)
        end

        @bytes_per_pixel = @bits_per_pixel / 8
        @data = FFI::MemoryPointer.new(:uint8, @width * @height * @bytes_per_pixel)

        FreeImage.FreeImage_ConvertToRawBits(
          @data, bmp_p, @width*@bytes_per_pixel, @bits_per_pixel,
          FreeImage::FI_RGBA_RED_MASK,
          FreeImage::FI_RGBA_GREEN_MASK,
          FreeImage::FI_RGBA_BLUE_MASK,
          1, # flip ? 1 : 0
        )
        if blk
          blk.call(self); destroy
        end
      end
      FreeImage.FreeImage_Unload(bmp_p) if bmp_p.address != 0
    end

    def destroy
      @data, @loaded = nil, false
    end
  end
end
end

$:.unshift( File.expand_path("../../lib", __FILE__) )
require 'ffi-cairo'

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
c.show_text("host: " + `uname -nmor`.chomp)

c.font_size = 15.0
c.move_to(10, 60)
c.show_text(`uptime`.chomp)

p c.text_extents("A"*10)

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

system("which feh && feh image.png")

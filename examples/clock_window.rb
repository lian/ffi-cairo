$:.unshift( File.expand_path("../../lib", __FILE__) )
require 'ffi-cairo'
require 'ffi-cairo/x11-window'


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



win = Cairo::X11::Window.new('cairo-canvas')

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

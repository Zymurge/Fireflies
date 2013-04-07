require 'gosu'
require_relative 'dot.rb'
require_relative 'dotManager.rb'
require_relative 'statsMachine.rb'

class DisplayWindow < Gosu::Window
 
  LEFTEDGE = 3
  TOPEDGE = 3
  RIGHTEDGE = 500
  BOTTOMEDGE = 400
  
  NUM_DOTS = 75
  NUM_OBSERVERS = 9
  FIXED_PULSE = 50
  THRESHOLD = 78
  REPORT_INTERVAL = 28

  def initialize
    super RIGHTEDGE+6, BOTTOMEDGE+6, false
    self.caption = "Fireflies"
    @rand = Random.new
    @dots = DotManager.new( NUM_DOTS, LEFTEDGE, RIGHTEDGE, TOPEDGE, BOTTOMEDGE, 
                            NUM_OBSERVERS, THRESHOLD, FIXED_PULSE )
    @font = Gosu::Font.new( self, Gosu::default_font_name, 12 )

    
    # stats stuff
    @machine = StatsMachine.new( @dots.dots )
    @interval = 0
    @show_stats = true
    @dot_cycles = @dot_pulse = 0
  end
    
  ##
  # Key functions:
  # + SPACE: Toggle Stats display (default on)
  # + ESC:   Quick quit
  #
  def button_down( id )
    if id == Gosu::KbSpace
      @show_stats = ! @show_stats
    end
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    @dots.dots.each do |dot|
      draw_dot( dot )
    end
    draw_stats
  end
 
  def update
    @dots.dots.each do |dot|
      cycle( dot )
    end
   
    update_stats
  end

  private
      
  def cycle( dot )
    pulse = @dots.next_pulse?( dot )
    dot.cycle!( pulse )
    # stat trackers
    @dot_cycles += 1
    @dot_pulse +=1 if pulse
  end
  
  def draw_dot( dot )
    return if nil == dot
    clr = dot.color
    # draw a 5x5 around the center point
    x1 = dot.x - 2
    x2 = dot.x + 2
    y1 = dot.y - 2
    y2 = dot.y + 2
    draw_quad( x1, y1, clr, x2, y1, clr, x2, y2, clr, x1, y2, clr )
    # draw a vertical 3x7
    x1 = dot.x - 1
    x2 = dot.x + 1
    y1 = dot.y - 3
    y2 = dot.y + 3
    draw_quad( x1, y1, clr, x2, y1, clr, x2, y2, clr, x1, y2, clr )
    # draw a vertical 3x7
    x1 = dot.x - 3
    x2 = dot.x + 3
    y1 = dot.y - 1
    y2 = dot.y + 1
    draw_quad( x1, y1, clr, x2, y1, clr, x2, y2, clr, x1, y2, clr )
  end

  def draw_stats
    if @show_stats
      @font.draw( "#{@stats_snapshot}", 10, 10, 2, 1.0, 1.0, 0xffffff00 )
    end
  end

  def update_stats
    @interval += 1
    if @interval % REPORT_INTERVAL == 0 then    
      adjustments = @dot_cycles - @dot_pulse
      @stats_snapshot = @machine.stats
      @interval = @dot_cycles = @dot_pulse = 0
      p "#{@stats_snapshot}, Adjustments: #{adjustments} in #{@dot_cycles} cycles"
    end
  end

end
  
window = DisplayWindow.new

if $DEBUG
  require 'debugger'
  debugger
end

window.show

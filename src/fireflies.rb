require 'gosu'
require 'texplay'

require_relative 'dot.rb'
require_relative 'dotManager.rb'
require_relative 'statsMachine.rb'
#require_relative 'circle.rb'

class DisplayWindow < Gosu::Window
 
  LEFTEDGE = 3
  TOPEDGE = 3
  RIGHTEDGE = 500
  BOTTOMEDGE = 400
  
  NUM_DOTS = 32
  NUM_OBSERVERS = 9
  FIXED_PULSE = 50
  THRESHOLD = 78
  REPORT_INTERVAL = 28

  Z_BACK = 0
  Z_DOT  = 3
  Z_HIGH = 5
  Z_TEXT = 9

  CLICK_RANGE = 8

  def initialize
    super RIGHTEDGE+6, BOTTOMEDGE+6, false
    self.caption = "Fireflies"
    @rand = Random.new
    @dots = DotManager.new( NUM_DOTS, LEFTEDGE, RIGHTEDGE, TOPEDGE, BOTTOMEDGE, 
                            NUM_OBSERVERS, THRESHOLD, FIXED_PULSE )
    @font = Gosu::Font.new( self, Gosu::default_font_name, 12 )

    # pre-create a circle image for highlighting
		@highlight_target  = create_highlight_circle( :red )
		@highlight_subject = create_highlight_circle( :blue )
    
    # stats stuff
    @machine = StatsMachine.new( @dots.dots )
    @interval = 0
    @show_stats = true
    @dot_cycles = @dot_pulse = 0

    # debug
    @debug_mode = false
    @movement_mode = true

  end
    
  ##
  # Key functions:
  # + SPACE: Toggle Stats display (default on)
  # + ESC:   Quick quit
  #
  def button_down( id )
		case id    
		when Gosu::MsLeft
      process_mouse_click
    when Gosu::KbSpace
      @show_stats = ! @show_stats
    when Gosu::KbEscape
      close
    when Gosu::KbD
      @debug_mode = !@debug_mode
		when Gosu::KbM
			@movement_mode = !@movement_mode
    end
  end

  def draw
    @dots.dots.each do |dot|
      draw_dot( dot )
    end
    draw_dot_highlight( @dots.highlighted_dot )

    draw_stats
    debug_cycle
  end
 
  def update
    @dots.dots.each do |dot|
      cycle( dot )
    end
   
    update_stats
  end

  private

	def create_highlight_circle( color )
    img = TexPlay::create_blank_image( self, 15, 15 )
    img.paint {
			circle( 7, 7, 7, :color => color, :thickness => 1 )
    }
		img
  end
      
  def cycle( dot )
    pulse = @dots.next_pulse?( dot )
    dot.cycle!( pulse, @movement_mode )
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
    draw_quad( x1, y1, clr, x2, y1, clr, x2, y2, clr, x1, y2, clr, Z_DOT )
    # draw a vertical 3x7
    x1 = dot.x - 1
    x2 = dot.x + 1
    y1 = dot.y - 3
    y2 = dot.y + 3
    draw_quad( x1, y1, clr, x2, y1, clr, x2, y2, clr, x1, y2, clr, Z_DOT )
    # draw a vertical 3x7
    x1 = dot.x - 3
    x2 = dot.x + 3
    y1 = dot.y - 1
    y2 = dot.y + 1
    draw_quad( x1, y1, clr, x2, y1, clr, x2, y2, clr, x1, y2, clr, Z_DOT )
  end

  def draw_dot_highlight( dot )
    return if nil == dot
    @highlight_target.draw( dot.x-7, dot.y-7, Z_HIGH )
    dot.observer.subjects.each do |sub|
      @highlight_subject.draw( sub.x-8, sub.y-8, Z_HIGH )
    end
  end

  def draw_stats
    if @show_stats
      @font.draw( "#{@stats_snapshot}", 10, 10, Z_TEXT, 1.0, 1.0, 0xffffff00 )
    end
  end

  def debug_cycle
    if @debug_mode
      @font.draw( "Debug on", RIGHTEDGE-50, 10, Z_TEXT, 1.0, 1.0, 0xffff3333 )
    end
  end


  ##
  # Overrides Gosu's default no cursor displayed mode
  def needs_cursor?
    true
  end

  def process_mouse_click
    p "Mouse clicked @ #{self.mouse_x},#{self.mouse_y}" if @debug_mode
    @dots.highlight_dot( mouse_x, mouse_y, CLICK_RANGE )
  end

  def update_stats
    @interval += 1
    if @interval % REPORT_INTERVAL == 0 then    
      adjustments = @dot_cycles - @dot_pulse
      @stats_snapshot = @machine.stats
      @interval = @dot_cycles = @dot_pulse = 0
      p "#{@stats_snapshot}, Adjustments: #{adjustments} in #{@dot_cycles} cycles" if @debug_mode
    end
  end

end
  
window = DisplayWindow.new

if $DEBUG
  require 'debugger'
  debugger
end

window.show

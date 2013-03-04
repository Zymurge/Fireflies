require 'Gosu'

# Represents all of the state for a single instance of a dot. Includes helper methods to trigger incremental changes in dot state.

class Dot
  
  # A unique identifier for a given dot instance
  attr_reader :id

  # The current coords of the dot
  attr_reader :x, :y

  # The delta applied to current x, y when the move method is called
  attr_reader :vec_x, :vec_y

  # The number of steps required before a toggle between lit and unlit occurs. A full cycle is 2X pulse length
  attr_reader :pulse

  # The current step number in a pulse sequence, counting a full cycle from lit through to the end of unlit (2X pulse)
  attr_reader :pulseStep
  
  # The observer instance for this dot instance
  attr_accessor :observer
  
  # The following class variables are set as global boundaries for the dot universe. 
  @@xMin = @@xMax = @@yMin = @@yMax = nil
  @@rand = nil
  
  ##
  # Generates a dot instance
  #=== Arguments
  # * id: A unique identifier for this instance
  # * x: the X coord
  # * y: the y coord
  # * color: a Gosu::Color instance
  # * pulse: the number increments before a color change occurs
  # * pulseStep: the current increment to start with.
  # * fadeSteps: the number of increments to fade through (greater than 0, less than pulse).
  # * totalFadePercent: the percentage of fade to apply at the end of the last step (0-100).
  def initialize( id, x, y, color, pulse, pulseStep=0, fadeSteps=5, totalFadePercent=80 )
    raise RuntimeError, "Must set boundaries for Dot class before constructing instance" if @@yMin.nil?
    
    @@rand = Random.new if @@rand.nil?  
    # raise RuntimeError, "Must set random for Dot class before constructing instance" if @@rand.nil?
    
    @id = id
    @x = x
    @y = y
    @pulseStep = pulseStep
    @pulse = pulse
    @fadeSteps = fadeSteps
    @vec_x = @vec_y = 0
    @lightPhases = Array.new
    @observer = nil

    # puts "#{to_s}"
    gen_light_phases( fadeSteps, color, totalFadePercent )
  end
  
  def to_s
    "x,y: #{coords_to_s} / pulse: #{@pulse} / current step: #{@pulseStep}"
  end
  
  ##
  # Returns the current coords in an +x, y+ format
  
  def coords_to_s
    "#{x},#{y}"
  end
  
  ##
  # Instructs the dot instance to cycle through a period of movement. Will pulse to the next color unless 
  # increment_pulse is false
  def cycle!( increment_pulse=true ) 
    @color = next_color if increment_pulse
    change_vector
    move
  end 
  
  ##
  # Returns boolean response about whether this instance is in a lit state. 
  # Cycling through the faded steps is considered not lit.
  def is_lit?
    return @pulseStep < @pulse
  end
  
  ##
  # Sets the class level boundaries. Must be called prior to initialization of an instance.
  def self.SetBoundaries( xmin, xmax, ymin, ymax ) 
    @@xMin = xmin
    @@xMax = xmax
    @@yMin = ymin
    @@yMax = ymax
  end
  
  ##
  # Can be used to pass in a random generator (or mock) or will be set as a singleton upon first instantiation of a dot
  def self.SetRandom( rand )
    @@rand = rand if rand.is_a? Random
  end
  
  private 
  
  def bounce
    @vec_x *= -1 if ( @x > @@xMax && @vec_x > 0 ) || ( @x < @@xMin && @vec_x < 0 )
    @vec_y *= -1 if ( @y > @@yMax && @vec_y > 0 ) || ( @y < @@yMin && @vec_y < 0 ) 
  end

  def change_vector( range=1 ) 
    if( @@rand.rand( 0..2 ) < 1 ) then
      @vec_x = @@rand.rand( range*-1..range ) 
      @vec_y = @@rand.rand( range*-1..range )
    end
    bounce
  end
  
  ##
  # The current color of this instance
  def color
    @lightPhases[@pulseStep]
  end
  
  def move
    @x += @vec_x
    @y += @vec_y
  end
  
  ##
  # Returns the correct color after incrementing pulse
  def next_color()
    @pulseStep += 1
    @pulseStep = 0 if @pulseStep >= @pulse*2
    color
  end
  
  ##
  # Returns the correct color after decrementing pulse
  def backstep_color()
    @pulseStep -= 1
    @pulseStep = @pulse * 2 if @pulseStep < 0
    color
  end

  def gen_light_phases( steps, firstColor, totalFadePercent )
    # debug
    # puts "genLightPhases.new( #{steps}, #{firstColor}, #{totalFadePercent} )"
    # gen the series of steps where color is at full brightness
    numLightSteps = @pulse - 1
    # numLightSteps = @pulse - steps
    for x in 0..numLightSteps
      @lightPhases[x] = firstColor
      # puts "Step #{x} gen color: #{@lightPhases[x].to_s}"
    end
    
    # determine the per step fade decrement
    fadePercent = totalFadePercent.to_f / 100
    fade = fadePercent / steps
    rDelta = ( firstColor.red * fade )
    gDelta = ( firstColor.green * fade )
    bDelta = ( firstColor.blue * fade )
    # puts "fadePercent: #{fadePercent} / fade: #{fade} / rDelta: #{rDelta}"
    
    # build the incremental fade colors
    steps.times do
      fade = @lightPhases[x]
      x += 1
      r = fade.red   - rDelta
      g = fade.green - gDelta
      b = fade.blue  - bDelta
      @lightPhases[x] = Gosu::Color.new( 255, r, g, b )
      # puts "Step #{x} gen color: #{@lightPhases[x].to_s}, obj: #{@lightPhases[x].inspect} previous: #{@lightPhases[x-1]}"
    end
    
    for x in (x+1)...(@pulse*2) do
      @lightPhases[x] = @lightPhases[x-1]
      # puts "Step #{x} gen color: #{@lightPhases[x].to_s}"
    end
    
  end

  
end

require 'dot.rb'
require 'dotObserver.rb'

# Creates and manages a collection of dot instances
class DotManager

  FIXED_PULSE = 50
  
  attr_reader :dots
  
  # Generates the specified number of dots, each randomly placed within the specified coordinate range
  
  def initialize( numDots, xMin, xMax, yMin, yMax , numObservees = 1, threshold = 50, fixedPulse = 0 )  
    raise RangeError, "numDots must be positive number" if numDots < 1
    @xMin = xMin; @xMax = xMax
    @yMin = yMin; @yMax = yMax
    raise RangeError, "X min must be less than X max" if @xMin >= @xMax
    raise RangeError, "Y min must be less than Y max" if @yMin >= @yMax
    @rand = Random.new
    @dots = gen_dots( numDots, fixedPulse )
    gen_observers( numObservees, threshold )
  end

  def gen_dots( num, pulse, step=0 )
    # Static members set required before instantiating dots
    Dot.SetBoundaries( @xMin, @xMax, @yMin, @yMax )
    Dot.SetRandom( @rand )
    
    dots = Array.new
    num.times do
      x = @rand.rand( @xMin...@xMax )
      y = @rand.rand( @yMin...@yMax )
      color = gen_color
      # a zero pulse means gen random
      #usePulse = @rand.rand( 40..76 ) if pulse == 0
      usePulse = pulse == 0 ? @rand.rand( 40..76 ) : pulse 
      useStep  = step == 0  ? @rand.rand( 0...usePulse*2 ) : step
      dots << Dot.new( dots.length, x, y, color, usePulse, useStep, 15, 80 )    
    end
    dots
  end
  
  def gen_observers( num, threshold )
    obs = Hash.new
    @dots.each do |me|
      myObs = DotObserver.new( @dots, me, @xMax, @yMax, num, threshold )
      me.observer = myObs
    end
  end
  
  def gen_color
    r = @rand.rand( 190..250 ) 
    g = @rand.rand( 160..220 )
    b = @rand.rand( 105..160 )
    color = Gosu::Color.new( 255, r, g, b )
    # puts "genColor: #{color.to_s}"
    color    
  end
  
  def observers_state_lit?( dot ) 
    raise RuntimeError, "DotManager.observers_state_lit? called for dot with nil observer" if dot.observer.nil?
    dot.observer.is_observed_average_lit?
  end
  
  def observers_to_s( dot )
    dot.observer.subjects_to_s
  end
  
  def stats
    lit = 0
    dark = 0
    @dots.each do |dot|
      if dot.isLit? then
        lit += 1
      else
        dark += 1
      end
    end
    
    percent = lit < dark ? 100 * dark / @dots.count : 100 * lit / @dots.count
    result = "Stats: Percent=#{percent}, lit=#{lit}, unlit=#{dark}"
    result
  end

  def adjust_threshold( dot )
    dot.observer.set_threshold_to_observers
  end
 
  def next_pulse?( dot )
    return if nil == dot
    obs_state = observers_state_lit?( dot )
    my_state  = dot.isLit?
    if ( $DEBUG && dot.id == 2 ) then
      p "Status: Dot ##{dot.id} @#{dot.coords_to_s} reflect: isLit: #{dot.isLit?}. Pulse #{dot.pulseStep}. Observed: #{obs_state}"
    end
  
    if ( obs_state == true && my_state == false ) then
      if ( $DEBUG && dot.id <= 2 ) then
        puts "Dot ##{dot.id} @#{dot.coords_to_s} adjusting to observees. isLit: #{dot.isLit?}. Pulse #{dot.pulseStep}. Threshold #{dot.observer.threshold}" 
      end
      # Observees lit, I'm not, don't go forward
      adjust_threshold( dot )
      return false
    end
    return true
  end
 
end
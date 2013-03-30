require_relative 'dot.rb'
require_relative 'movingAverage.rb'

class StatsMachine
  
  def initialize ( dots_list )
    @dots = dots_list   
    @ma = MovingAverage.new( 100 ) 
  end
  
  def update
    lit = 0
    dark = 0
    @dots.each do |dot|
      if dot.is_lit? then
        lit += 1
      else
        dark += 1
      end
    end
    
    percent = lit < dark ? 100 * dark / @dots.count : 100 * lit / @dots.count
    @ma.push_period( percent )
  end
  
  def stats
    update
    result = "Stats: Percent=#{@ma.last_period}, ma10=#{@ma.average( 10 )}"
    result
  end
  
  # Returns the specified number of last periods, ordered from most recent to least
  def periods( num )
    #ma.
  end

end

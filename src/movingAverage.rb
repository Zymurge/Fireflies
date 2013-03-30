##
# Provides functionality to collect N periods of data and to generate a moving average of the 
# requested number of previous periods. Uses a rolling buffer to age out period N+1 as new
# entries are added. 
# Works with input as either integers or strings containing integer values.
#
#--
#
# TODO:
# * add floating point functionality
# * provide averages for periods other than ending with the most recent addition

class MovingAverage
  
  ##
  # The number of periods tracked by this object
  attr_reader :max_periods
  
  ##
  # Creates an instance of size _max_periods_ with all initial values set to zero.
  # Raises ArgumentError if the input format is not either an Integer or a string that parses to Integer
  def initialize( max_periods )
    raise ArgumentError, "max_periods must be numeric" if ! Integer( max_periods )
    @max_periods = Integer( max_periods )
    @periods = Array.new( @max_periods, 0 )
    @idx = 0    
  end
  
  ##
  # Returns the average value for the last _num_periods_
  def average( num_periods )
    total = 0
    curr = @idx
    num_periods.times do
      curr = prev_index( curr ) 
      total += @periods[curr]
    end
    total / num_periods  
  end
  
  ##
  # Adds the specified _value_ as the most recent period, aging out the oldest entry if needed
  def push_period( value )
    raise ArgumentError, "push_period 'value' param must be numeric" if ! Integer( value )
    myValue = Integer( value )
    @periods[@idx] = myValue
    @idx = next_index( @idx )   
  end
  
  ##
  # Returns the value of the last period entered
  def last_period
    @periods[prev_index( @idx )]    
  end
  
  ##
  # Returns an array of the last _num_ of periods in LIFO order
  def fetch_periods( num )
    result = Array.new( num )
    i = prev_index( @idx )
    num.times do |j|
      i = prev_index( i )
      result[j-1] = @periods[i]
    end
    result
  end
  
  private
  
  def next_index( curr )
    n = curr + 1 < @max_periods ? curr + 1 : 0
    n
  end
  
  def prev_index( curr )
    n = curr > 0 ? curr - 1 : @max_periods -1
    n
  end
 
end

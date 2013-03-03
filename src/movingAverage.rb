class MovingAverage
  
  attr_reader :max_periods
  
  def initialize( max_periods )
    raise ArgumentError, "max_periods must be numeric" if ! Integer( max_periods )
    @max_periods = Integer( max_periods )
    @periods = Array.new( @max_periods, 0 )
    @idx = 0    
  end
  
  def average( num_periods )
    total = 0
    curr = @idx
    num_periods.times do
      curr = prev_index( curr ) 
      total += @periods[curr]
    end
    total / num_periods  
  end
  
  def push_period( value )
    raise ArgumentError, "push_period 'value' param must be numeric" if ! Integer( value )
    myValue = Integer( value )
    @periods[@idx] = myValue
    @idx = next_index( @idx )   
  end
  
  def last_period
    @periods[prev_index( @idx )]    
  end
  
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
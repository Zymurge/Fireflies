require 'test/unit'
require_relative '../src/statsMachine.rb'

class TestStatsMachine < Test::Unit::TestCase
  
  def setup
    # create an array of dots to manipulate for tests. Start with all even indexes dark and odds lit
    Dot.SetBoundaries( 0, 0, 100, 100 )
    @c1 = Gosu::Color.new( 255, 200, 200, 200 )
    
    @dot_lit  = Dot.new( 5, 10, 10, @c1, 10, 0 )
    @dot_dark = Dot.new( 6, 10, 10, @c1, 10, 11 )

    @dots = Array.new( 10 )
    
    @dots.each_with_index do | dot, i |
      @dots[i] = i%2 == 0 ? @dot_dark.clone : @dot_lit.clone
  end
    
  end
  
  def testInitialize
    sm = StatsMachine.new( @dots )
    assert_not_nil( sm, "Initizialize broke and return nil" )
    assert_instance_of( StatsMachine, sm, "Initialized wrong type somehow" )
  end
  
  def testUpdateAndFetch
    sm = StatsMachine.new( @dots )
    sm.update
    actual = sm.periods( 1 )
    assert_equal( 50, actual, "Initial percent for untouched standard test array should be 50")
  end
  
  # ensure that a set of periods are retrieved, in LIFO order
  def testPeriods
    expected = [ 70, 60, 50 ]
    sm = StatsMachine.new( @dots )
    
    # push initial state of 50
    sm.update
    
    # set to 60 and push
    @dots[1] = @dot_dark.clone
    sm.update
    
    # set to 70 and push
    @dots[3] = @dot_dark.clone
    sm.update
    
    actual = sm.periods( 3 )
    assert_equal( expected, actual, "LIFO not as we know it" )
  end
  
end


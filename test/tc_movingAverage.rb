require 'test/unit'
require_relative '../src/movingAverage.rb'

class TestMovingAverage < Test::Unit::TestCase
  
  def testInitialize
    periods = 10
    ma = MovingAverage.new( periods )
    assert_instance_of( MovingAverage, ma, "Did instantiate correct type" )
    actual = ma.max_periods
    assert_equal( periods, actual, "Expected size doesn't match" )
  end
  
  def testInitializeNonNumeric
    assert_raise( ArgumentError ) {
      ma = MovingAverage.new( "Raise this!" )
    }
  end
  
  def testGetAverageBeforeAnyValuesAdded
    periods = 10
    expected = 0
    ma = MovingAverage.new( periods )
    actual = ma.average( periods )
    assert_equal( expected, actual, "MovingAverage without adding values should be 0" )
  end
  
  def testGetAverageBeforeAllValuesAdded
    periods = 6
    expected = 4
    ma = MovingAverage.new( periods )
    ma.push_period( 20 )
    ma.push_period( 4 )
    actual = ma.average( periods )
    assert_equal( expected, actual, "MovingAverage should have zeroes used for unpopulated periods" )
  end
  
  def testAverageAfterRollingPeriods
    periods = 4
    ma = MovingAverage.new( periods )
    
    # populate overflow number of periods with an increasing value
    x = 0
    6.times do
      x += 2
      ma.push_period( x )
    end
    
    # expected end result are values [ 6, 8, 10, 12 ]
    expected = ( 6 + 8 + 10 + 12 ) / periods
    actual = ma.average( periods )
    assert_equal( expected, actual, "MovingAverage should be calculated for most recent periods after rolling over" )
  end
  
  def testPushAndGetLast
    periods = 4
    expected = 10
    ma = MovingAverage.new( periods )
    ma.push_period( expected )
    actual = ma.last_period
    assert_equal( expected, actual, "last_period should fetch most recent push" )
    
    # be sure that pushing the next doen't keep returning the same value
    expected =+ 13
    ma.push_period( expected )
    actual = ma.last_period
    assert_equal( expected, actual, "last_period appears to be grabbing the wrong value" )
  end
  
  def testPush_PeriodNonNumericValue
    periods = 4
    ma = MovingAverage.new( periods )
    assert_raise( ArgumentError ) {
      ma.push_period( "Raise this!" )
    }
  end
  
  def testFetch_Periods
    expected = [ 1, 2, 3, 5, 8 ]
    ma = MovingAverage.new( expected.count + 3 )
    
    expected.reverse_each do |e|
      ma.push_period( e )
    end
    
    actual = ma.fetch_periods( expected.count )
    assert_equal( expected, actual, "LIFO does not exist here" )
  end
  
end

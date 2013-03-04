require 'test/unit'
require 'dotManager.rb'

class TestDotManager_Initializer < Test::Unit::TestCase
  
  def testPositive
    dm = DotManager.new( 10, 0, 100, 1, 99 )
    assert_not_nil( dm, "Initialize failed to create instance" )
    assert_instance_of( DotManager, dm, "Initialize failed to create proper instance type" )
  end
  
  # DotManager must enforce a positive number of dots as first argument
  def testPositiveDots
    assert_raise( RangeError ) {
      dm = DotManager.new( 0, 0, 100, 1, 99 )
    }
  end
  
  # DotManager must enforce that minX is less than maxX, and likewise for the Y ranges
  def testMinMax
    assert_raise( RangeError ) {
      dm = DotManager.new( 1, 100, 90, 0, 50 )
    }
    assert_raise( RangeError ) {
      dm = DotManager.new( 1, 10, 90, 20, 19 )
    }
  end
  
  def testDotGeneration
    expectedDots = 100
    dm = DotManager.new( expectedDots, 0, 100, 0, 100 )
    actualDots = dm.dots.length
    assert_equal( expectedDots, actualDots, "Should generate the number of dots specified at initialization")
  end
  
end

class DeprecatedTests
  
  # deprecated as Dotobserver abstracted out
   def testDotObservers
    expectedDots = 100
    expectedObsPerDot = 6
    dm = DotManager.new( expectedDots, 0, 100, 0, 100, expectedObsPerDot )
    # pick a dot and count the number of observers generated
    aDot = dm.dots[5]
    # set the dot to a far corner so that it will find at least 6 subjects before it finds middle
    aDot.x = 0; aDot.y = 0
    aDot.observer.
    actualObsPerDot = aDot.observer.subjects.count
    assert_equal( expectedObsPerDot, actualObsPerDot, "Should generate the specified number of oberversees per dot")
  end

end
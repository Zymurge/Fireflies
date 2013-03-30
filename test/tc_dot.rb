require 'test/unit'
load 'testBoolean.rb'
require 'gosu'
require_relative '../src/dot.rb'

class TestDots < Test::Unit::TestCase
    
  def setup
    @aColor = Gosu::Color.new( 255, 200, 200, 200 )
  end
  
  def setDotSelfVariables
    Dot.SetBoundaries( 1, 100, 5, 500 )
    Dot.SetRandom( Random.new )
  end
  
  def clearDotSelfVariables
    Dot.SetBoundaries( nil, nil, nil, nil )
    Dot.SetRandom( nil )
  end

  def testInitializeCorrectClass
    setDotSelfVariables
    d = Dot.new( 13, 10, 20, @aColor, 25 )
    assert_instance_of( Dot, d, "Expected a Dot damnit!" )
  end
 
  def testInitializeAttributes
    setDotSelfVariables
    d = Dot.new( 13, 10, 20, @aColor, 25 )
    assert_equal( d.id, 13 )
    assert_equal( d.x, 10 )
    assert_equal( d.y, 20 )
    assert_equal( d.color, @aColor )
  end

  def testInitializeBeforeSelfVariablesSet
    clearDotSelfVariables
    assert_raise( RuntimeError ) {
      d = Dot.new( 1, 2, 3, @aColor, 5 )
    }
  end
    
  def testInitializeBeforeBoundariesSet
    clearDotSelfVariables       
    Dot.SetRandom( Random.new )
    assert_raise( RuntimeError ) {
      d = Dot.new( 1, 2, 3, @aColor, 5 )
    }
  end
    
=begin
   Expect that with a pulse of 5 and 2 step, 50% fade pattern:
   * Step 0-4; initial color
   * Step 5: 25% reduction in rgb attributes
   * Step 6: 50% reduction in rgb attributes
   * Step 7-9: as step 3
   * Step 10: return to initial step 0 state
=end
  def testColorChange
    setDotSelfVariables
    @aColor = Gosu::Color.new( 255, 200, 200, 200 )
    @bColor = Gosu::Color.new( 255, 150, 150, 150 )
    @cColor = Gosu::Color.new( 255, 100, 100, 100 )
    d = Dot.new( 99, 10, 20, @aColor, 5, 0, 2, 50 )
    assert_equal( d.color, @aColor, "At step 0 expect lit color" )
    4.times do d.cycle! end
    assert_equal( d.pulseStep, 4, "Pulse should be 4 at this point")
    assert_equal( d.color, @aColor, "At step 4 still expect lit color" )
    d.cycle!
    assert_equal( d.color, @bColor, "At step 6 expect first fade step" )
    d.cycle!
    assert_equal( d.color, @cColor, "At step 7 expect second fade step" )
    4.times do d.cycle! end
    assert_equal( d.pulseStep, 0, "Pulse should have wrapped around after 3x2 cycles") #step 11
    assert_equal( d.color, @aColor )       
  end
  
  def testIsLitThroughCycle
    setDotSelfVariables
    # p "Start testIsLitThroughCycle"
    @aColor = Gosu::Color.new( 255, 200, 200, 200 )
    d = Dot.new( 19, 10, 20, @aColor, 12, 0, 2, 50 )
    assert_true( d.is_lit?, "A newly built dot should start lit" )

    # cycle until color change is detected
    d.cycle!
    while( d.color == @aColor )
      assert_true( d.is_lit?, "A dot should be lit with start color active" )
      d.cycle!
    end
    # p "pulse: #{d.pulse}, pulseStep: #{d.pulseStep}"
    assert_false( d.is_lit?, "A dot should not be lit when color fade begins" )
    # cycle until color restores to normal
    d.cycle!
    while( d.color != @aColor )
      assert_false( d.is_lit?, "A dot should not be lit until color returns to start")
      d.cycle!
    end
    assert_true( d.is_lit?, "A dot should be lit when color is active after a cycle" )   
  end
  
end

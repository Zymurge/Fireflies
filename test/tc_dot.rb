require 'test/unit'
require 'dot.rb'
require 'gosu'

class TestDots < Test::Unit::TestCase
    
  def setup
    @aColor = Gosu::Color.new( 255, 200, 200, 200 )
  end
  
  def setDotClassMembers
    Dot.SetBoundaries( 1, 100, 5, 500 )
    Dot.SetRandom( Random.new )
  end
  
  def testInitializeCorrectClass
    setDotClassMembers
    d = Dot.new( 13, 10, 20, @aColor, 25 )
    assert_instance_of( Dot, d, "Expected a Dot damnit!" )
  end
 
  def testInitializeAttributes
    setDotClassMembers
    d = Dot.new( 13, 10, 20, @aColor, 25 )
    assert_equal( d.id, 13 )
    assert_equal( d.x, 10 )
    assert_equal( d.y, 20 )
    assert_equal( d.color, @aColor )
  end

  def testInitializeAfterClassMembersSet
    assert_raise( RuntimeError ) {
      d = Dot.new( 1, 2, 3, @aColor, 5 )
    }
  end
    
  def testInitializeBeforeBoundariesSet
    Dot.SetBoundaries( 1, 100, 2, 200 )
    assert_raise( RuntimeError ) {
      d = Dot.new( 1, 2, 3, @aColor, 5 )
    }
  end
    
  def testInitializeBeforeBoundariesSet
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
    setDotClassMembers
    @aColor = Gosu::Color.new( 255, 200, 200, 200 )
    @bColor = Gosu::Color.new( 255, 150, 150, 150 )
    @cColor = Gosu::Color.new( 255, 100, 100, 100 )
    d = Dot.new( 99, 10, 20, @aColor, 5, 0, 2, 50 )
    assert_equal( d.color, @aColor, "At step 0 expect lit color" )
    4.times do d.move end
    assert_equal( d.pulseStep, 4, "Pulse should be 4 at this point")
    assert_equal( d.color, @aColor, "At step 4 still expect lit color" )
    d.move
    assert_equal( d.color, @bColor, "At step 6 expect first fade step" )
    d.move
    assert_equal( d.color, @cColor, "At step 7 expect second fade step" )
    4.times do d.move end
    assert_equal( d.pulseStep, 0, "Pulse should have wrapped around after 3x2 moves") #step 11
    assert_equal( d.color, @aColor )       
  end
  
  def testIsLitThroughCycle
    setDotClassMembers
    # p "Start testIsLitThroughCycle"
    @aColor = Gosu::Color.new( 255, 200, 200, 200 )
    d = Dot.new( 19, 10, 20, @aColor, 12, 0, 2, 50 )
    assert_true( d.isLit?, "A newly built dot should start lit" )

    # move until color change is detected
    d.move
    while( d.color == @aColor )
      assert_true( d.isLit?, "A dot should be lit with start color active" )
      d.move
    end
    # p "pulse: #{d.pulse}, pulseStep: #{d.pulseStep}"
    assert_false( d.isLit?, "A dot should not be lit when color fade begins" )
    # move until color restores to normal
    d.move
    while( d.color != @aColor )
      assert_false( d.isLit?, "A dot should not be lit until color returns to start")
      d.move
    end
    assert_true( d.isLit?, "A dot should be lit when color is active after a cycle" )   
  end
  
end
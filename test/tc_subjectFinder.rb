require 'test/unit'
require 'gosu'
require_relative '../src/subjectFinder.rb'
require_relative '../src/dot.rb'

class TestBetween < Test::Unit::TestCase
    
  def testTrueMid
    assert_true( SubjectFinder.between?( 23, 5, 33 ), "Expected 5 <= 23 <= 33 when P1 < P2" )
    assert_true( SubjectFinder.between?( 18, 33, 5 ), "Expected 5 <= 18 <= 33 when P1 > P2" )
  end

  def testEqualsP1
    assert_true( SubjectFinder.between?( 23, 23, 33 ), "Expected 23 <= 23 <= 33 when P1 < P2" )
    assert_true( SubjectFinder.between?( 23, 33, 23 ), "Expected 23 <= 23 <= 33 when P1 > P2" ) 
  end

  def testEqualsP2
    assert_true( SubjectFinder.between?( 23, 5, 23 ), "Expected 5 <= 23 <= 23 when P1 < P2" )
    assert_true( SubjectFinder.between?( 23, 23, 2 ), "Expected 2 <= 23 <= 23 when P1 > P2" )  
  end
  
  def testFalseLow
    assert_false( SubjectFinder.between?( 2, 5, 23 ), "Expected 2 < 5 when P1 < P2" )
    assert_false( SubjectFinder.between?( 23, 125, 93 ), "Expected 23 < 93 when P1 > P2" )      
  end
  
end

class TestSubjectFinder < Test::Unit::TestCase
  
  def setup
    @c1 = Gosu::Color.new( 255, 200, 200, 200 )

    @dotMe = Dot.new( 1, 50, 50, @c1, 10 )
    @dotList = [
      Dot.new(  2,  10,  10, @c1, 20 ),
      Dot.new(  3,  20, 150, @c1, 20 ),
      @dotMe,
      Dot.new(  4,  30,  10, @c1, 20 ),
      Dot.new(  5, 250, 100, @c1, 13 ),
      Dot.new(  6, 300, 300, @c1, 42 )
    ]
    
    @dot_lit  = Dot.new( 21, 0, 0, @c1, 10, 0 )
    @dot_dark = Dot.new( 22, 0, 0, @c1, 10, 11 )
  end    

  def testInit
    sf = SubjectFinder.new( @dotList, @dotMe, 400, 400 )
    assert_not_nil( sf, "Initialize failed to create instance" )
    assert_instance_of( SubjectFinder, sf, "Initialize failed to create proper instance type" )
  end  

  def testFindNearest
    sf = SubjectFinder.new( @dotList, @dotMe, 400, 400 )
    results = sf.find_nearest( 2 )
    result4 = results[0]
    result2 = results[1]
    assert_equal( result4.id, 4, "Expected id of 1st closest dot to be 4" )
    assert_equal( result2.id, 2, "Expected id of 2nd closest dot to be 2" )
  end
  
end

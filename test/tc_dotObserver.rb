require "test/unit"
require_relative "../dotObserver.rb"
require_relative "../dot.rb"
require 'gosu'

class TestDotObserver < Test::Unit::TestCase

  def setup
    Dots.SetBoundaries( 100, 100 )
    
    @c1 = Gosu::Color.new( 255, 200, 200, 200 )
    
    @dotMe = Dot.new( 99, 5, 5, @c1, 10 )
    @dotList = [
      Dot.new( 0, 10, 10, @c1, 20 ),
      Dot.new( 1, 20, 10, @c1, 20 ),
      @dotMe,
      Dot.new( 2, 30, 20, @c1, 20 ),
      Dot.new( 3, 5,  5,  @c1, 13 ),
      Dot.new( 4, 8, 100, @c1, 42 )
    ]
    
    @dot_lit  = Dot.new( 5, 10, 10, @c1, 10, 0 )
    @dot_dark = Dot.new( 6, 10, 10, @c1, 10, 11 )
    
  end    

  def testInitializeFailsOnNonListParam
    assert_raises( ArgumentError ) {
      d = DotObserver.new( "I'm not a list" )      
    }
  end
  
  def testInitializeCorrectClass
    d = DotObserver.new( @dotList, @dotMe, 100, 100, 4 )
    assert_instance_of( DotObserver, d, "Expected a DotObserver damnit!" )
  end
   
  def testInitializeEnforceDotListContents
  	# add 2 more items to keep number in list odd, and make one a non-dot object
  	@dotList << "I'm not a dot"
  	@dotList << @dot_dark
  	assert_raises( TypeError, "Expect initialize to enforce input list contains exclusively dot objects" ) {
  	  d = DotObserver.new( @dotList, @dotMe, 100, 100, 1 )
  	}
  end
  
  def testEnforcesubjectCountLessThanAvailable
    tooBig = @dotList.count
    assert_raises( ArgumentError, "Expect initialize to enforce a number of subjects no more than are availabie in list - 1" ) {
      d = DotObserver.new( @dotList, @dotMe, 100, 100, tooBig )
    }
    tooBig = @dotList.count + 1
    assert_raises( ArgumentError, "Expect initialize to enforce a number of subjects no more than are availabie in list - 1" ) {
      d = DotObserver.new( @dotList, @dotMe, 100, 100, tooBig )
    }
  end
  
  def testObserversAreDots
    d = DotObserver.new( @dotList, @dotMe, 100, 100, 3 )
    o = d.subjects
    actual = o[1]
    assert_not_nil( actual, "Nil values in subjects list. Not cool!")
    assert_instance_of( Dot, actual, "subject should be of type Dot")
  end
  
  def testCorrectNumSubjects
    actualSubjects = 3
    #@dotMe.x = 0; @dotMe.y = 0
    d = DotObserver.new( @dotList, @dotMe, 100, 100, actualSubjects )
    expected = d.subjects.count
    assert_equal( expected, actualSubjects, "Initializer should generate the specified number of subjects" )
  end
	
  def testObserveAverageLitStateIsOn
    dotList = [ @dot_lit.clone, @dot_lit.clone, @dotMe, @dot_dark.clone, @dot_lit.clone, @dot_dark.clone ]
    # puts "\ntestObserveAverageLitStateIsOn begin ..."
    d = DotObserver.new( dotList, @dotMe, 100, 100, 5 )
    state = d.is_observed_average_lit?
#    assert_equal( state, true, "3 of 5 lit dots should return true" )
    assert_true( state, "3 of 5 lit dots should return true" )
  end

  def testObserveAverageLitStateIsOff
    dotList = [ @dot_lit.clone, @dot_dark.clone, @dot_dark.clone, @dotMe ]
    # puts "\ntestObserveAverageLitStateIsOff begin ..."
    d = DotObserver.new( dotList, @dotMe, 100, 100, 3 )
    assert_equal( d.subjects.count, 3, "test DotObserver created wrong number of subjects")
    state = d.is_observed_average_lit?
    # puts "state: #{state}"
    assert_false( state, "1 of 3 lit dots should return false" )
  end
  
  def testSelectSubjects
    myDot = Dot.new( 99, 90, 88, @c1, 20 )
    test1 = Dot.new( 0,  89, 88, @c1, 20 )
    test2 = Dot.new( 1,  90, 80, @c1, 20 )
    test3 = Dot.new( 2,  77, 78, @c1, 20 )
    candidates = [
      Dot.new( 11, 90, 89, @c1, 20 ),
      Dot.new( 12, 10, 21, @c1, 20 ),
      Dot.new( 13, 19, 22, @c1, 20 ),
      Dot.new( 14, 15, 28, @c1, 20 ),
      Dot.new( 15, 78, 78, @c1, 20 ),
      Dot.new( 16, 41, 33, @c1, 20 ),
      test2,
      Dot.new( 17, 77, 80, @c1, 20 ),
      test3,
      Dot.new( 18, 99, 99, @c1, 20 ),
      Dot.new( 19, 80, 79, @c1, 20 ),
      Dot.new( 20, 15, 28, @c1, 20 ),
      test1
    ]
    
    result = DotObserver.new( candidates, myDot, 100, 100, 5 ).subjects
    # debug
    result.each do |dot|
      p "Dot id:#{dot.id}"
    end
    
    assert_not_nil( result, "DotObserver.select_subjects should not return nil object, array expected" )
    assert_instance_of( Array, result, "DotObserver.select_subjects should return an array of dot isntances" )
    assert_in_list( test1, result, "Expected item in closest 5 neighbors list" )
    assert_in_list( test2, result, "Expected item in closest 5 neighbors list" )
    assert_not_in_list( test3, result, "Expected item should not have made closest 5 neighbors list" )
  end
  
  def assert_in_list( test, list, message )
    assert_not_nil( list.index( test ), message )
  end
    
  def assert_not_in_list( test, list, message )
    assert_nil( list.index( test ), message )
  end

  def dumpDotListLightState( dotList )
    puts "\nDumping dot list:"
    dotList.each do |dot|
      puts "  #{dot.isLit?}"
    end
    puts "End dump"
  end
  
  def DEPRECATED_testInitializeEnforceOddNumber
    assert_equal( @dotList.count, 3, "Reusable input list should have 3 (odd) arguments" )
    d = DotObserver.new( @dotList )
    assert_not_nil( d, "Expected odd number list to pass initialization" )
    @dotList << @dot_lit
    assert_raises( ArgumentError, "Input list with 4 items should get bounced" ) {
      d = DotObserver.new( @dotList )
    }
  end
      
end
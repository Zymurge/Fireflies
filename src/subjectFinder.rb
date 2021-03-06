class SubjectFinder
  
  attr_accessor :t
  
  def initialize( candidates, me, size_x, size_y )
    @me = me
    # store the center coords
    @x = size_x / 2
    @y = size_y / 2
    
    # strip myself out of the list
    @candidates = Array.new
    candidates.each do |dot|
      @candidates << dot unless dot == @me
    end    
    
    # call the first distance ranking before everyone starts moving
    rank_distances
  end
  
  def rank_distances
    @distances = Array.new
    @candidates.each_with_index do |dot, i|
      #puts "dot=#{dot}, i=#{i}"
      # in theory, no need to do expensive sqrt since we're only looking at relative distances
      range = ( @me.x - dot.x )**2 + ( @me.y - dot.y )**2
      @distances << [ range, i ]
    end
    @distances.sort!
  end
  
  def find_nearest( number )
    rank_distances
    return build_nearest_list( number )
  end
    
  def build_nearest_list( number )
    topRanges = @distances.take( number )
    subjects = Array.new
    topRanges.each do | k, v |
      subjects << @candidates[v]
    end
    return subjects
  end
  
  def find_next_centered( number )
    found = 0
    subjects = Array.new
    @distances.each do | k, v |
      dot = @candidates[v]
      if more_centered?( dot )
        subjects << @candidates[v]
        found += 1
      end
      break if found == number     
    end  
    
    # if there aren't enough towards center than round out the group with the next nearest
    # note: this create potential double mapping of nearby and more central dots creating a weighted bias for those
    #       I think that's a good thing
    if number < found then
      moreSubjects = build_nearest_list( number - found )
      subjects += moreSubjects
      subjects.flatten!
    end  
    
    return subjects
  end
  
  def more_centered?( dot )
    SubjectFinder.between?( dot.x, @me.x, @x ) && SubjectFinder.between?( dot.y, @me.y, @y )
  end
  
  # Returns true if the value of mid is between p1 and p2, inclusive of the end points
  def self.between?( mid, p1, p2 )
    return true if mid >= p1 && mid <= p2
    return true if mid >= p2 && mid <= p1
    return false
  end
  
end

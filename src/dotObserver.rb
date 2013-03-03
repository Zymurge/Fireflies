require_relative 'subjectFinder.rb'

# This class manages what a given dot can observe from a collection of other dots
class DotObserver

  attr_reader :me, :subjects, :threshold
  
  def initialize( dotsList, me, x, y, numObservers=1, threshold=50 )
    raise ArgumentError, "DotObserver requires a list" unless dotsList.class == Array
    raise ArgumentError, "DotObserver requires less observers than are in the dotsList, exclusive of me" unless dotsList.count > numObservers
    validate_list_content( dotsList, Dot )
    @dots = dotsList
    @me = me
    @numObserver = numObservers
    @threshold = threshold
    @finder = SubjectFinder.new( @dots, @me, x, y )
    @subjects = @finder.find_next_centered( @numObserver )
    #raise RuntimeError, "DotObserver.initialize created #{@subjects.count} of the specified #{numObservers} subjects" unless @subjects.count == numObservers
  end

  # ups the threshold to 1 percent less than current set of observers if the current threshold is not already above this level
  def set_threshold_to_observers
    return # temp short circuit
    adjusted = observed_average - 1
    @threshold = adjusted > @threshold ? adjusted : @threshold
  end  

  def validate_list_content( list, classType )
    list.each do |item|
      raise TypeError, "Expected type #{classType} for all elements" unless item.instance_of? classType
    end
  end

  def subjects_to_s
    result = "AVG: #{is_observed_average_lit?} - "
    subjects.each do |s|
      result += "id##{s.id}:#{s.isLit?}; "
    end
    result
  end
  
  # returns true if the majority of observered dots are currently in a lit state
  # majority defined as having a higher percent lit than the current threshold
  def is_observed_average_lit?
   percentLit = observed_average
   percentLit > @threshold
  end

  # Returns the percentage of observees that are lit
  def observed_average
    # once per full cycle scan for next set of subjects
    @finder.rank_distances if @me.pulseStep == 0

    total = 0
    @subjects = @finder.find_next_centered( @numObserver )
    @subjects.each do |dot|
      raise RuntimeError, "expected Dot instance, got #{dot.class}" unless dot.instance_of? Dot
      total += 100 if dot.isLit?
      # puts "observe: #{dot.isLit?} / total: #{total}"
    end
    percentLit = total / @subjects.length
    
    # potential fix to prevent near middle dot from chasing too few observers
    percentLit = 0 if @subjects.length == 0
    
    percentLit
  end
  
  ##
  # Used to generate the most appropriate list for a given dot to observe.
  #
  #== Args:
  #  me: the dot that will be doing the observing
  #  candidates_list: the super set of dots that can be observed
  #  num_observed: the number to select
  #
  #== Returns:
  #  a list of dot objects
  def select_subjects_closest( candidates_list, me, num_subjects )
    # puts "select_subjects: called with #{candidates_list.count} candidates, me=#{me}, #{num_subjects} subjects"

    candidates = Array.new
    distance = Array.new
    candidates_list.each_with_index do |dot, i|
      #puts "dot=#{dot}, i=#{i}"
      range = Math.sqrt( ( me.x - dot.x )**2 + ( me.y - dot.y )**2 ).to_int
      # to prevent observing self and to prevent throwing off coordinated indexes, set 'me' to furthest possible
      range = 65535 if me == dot
      candidates << dot
      distance << [ range, i ]
    end
    distance.sort!
    topRanges = distance.take( num_subjects )
    subjects = Array.new
    topRanges.each do | k, v |
      subjects << candidates[v]
    end
    return subjects
  end

  ##
  # Used to generate the most appropriate list for a given dot to observe.
  #
  #== Args:
  #  me: the dot that will be doing the observing
  #  candidates_list: the super set of dots that can be observed
  #  num_observed: the number to select
  #
  #== Returns:
  #  a list of dot objects
  def select_subjects_central( candidates_list, me, num_subjects, size_x, size_y )
    # puts "select_subjects: called with #{candidates_list.count} candidates, me=#{me}, #{num_subjects} subjects"

    candidates = Array.new
    distance = Array.new
    candidates_list.each_with_index do |dot, i|
      #puts "dot=#{dot}, i=#{i}"
      range = Math.sqrt( ( me.x - dot.x )**2 + ( me.y - dot.y )**2 ).to_int
      # to prevent observing self and to prevent throwing off coordinated indexes, set 'me' to furthest possible
      range = 65535 if me == dot
      candidates << dot
      distance << [ range, i ]
    end
    distance.sort!
    
    found = 0
    subjects = Array.new
    distance.each do | k, v |
      dot = candidates[v]
      if more_centered?( me, dot )
        subjects << candidates[v]
        found += 1
      end
      break if found == num_subjects     
    end
    
    return subjects
  end

end
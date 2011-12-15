require 'polaris/version'

require 'algorithms'
require 'pry'
include Algorithms::Containers

# Polaris is a star that guides, aka "The North Star".  It implements the A* algorithm.
class Polaris
  attr_reader :nodes_considered

  def initialize(map)
    @map = map
    @nodes_considered = 0
  end

  # Returns the path without the from location. 
  # Returns nil if max_depth is hit or if no path exists.
  def guide(from, to, unit_type=nil, max_depth=400)
    return nil if @map.blocked?(from, unit_type) || @map.blocked?(to, unit_type)
    from_element = PathElement.new(from)
    from_element.dist_from = @map.distance(from,to)
    open = PrioritySet.new
    open.push from_element, from_element.rating
    closed = SplayTreeMap.new
    step = 0

    until open.empty? || step > max_depth
      step += 1

      current_element = open.pop
      @nodes_considered += 1

      loc = current_element.location
      if @map.cost(loc,to) == 0
        path = []
        until current_element.parent.nil?
          path.unshift current_element
          current_element = current_element.parent
        end

        return path
      else
        closed.push loc, current_element
        @map.neighbors(loc).each do |next_door|
          if closed.has_key? next_door
            next
          end
          
          el = PathElement.new(next_door,current_element)

          if @map.blocked? next_door, unit_type
            closed.push el.location, el
          else
            current_rating = current_element.cost_to + @map.cost(loc, next_door)

            # add to open
            el.cost_to = current_rating
            el.dist_from = @map.distance(next_door,to)
            el.reset_rating

            open.push el, el.rating
          end
        end
      end
    end
    nil
  end
end

class PathElement
  include Comparable

  attr_accessor :location, :parent
  attr_reader :cost_to, :dist_from, :rating
  def initialize(location=nil,parent=nil)
    @location = location
    @parent = parent
    @cost_to = 0
    @dist_from = 0
    @rating = 99_999
  end

  def cost_to=(new_cost)
    @cost_to = new_cost
    reset_rating
  end

  def dist_from=(new_dist_from)
    @dist_from = new_dist_from
    reset_rating
  end

  def reset_rating
    @rating = @cost_to + @dist_from
  end

  def to_s
    "#{@location} at cost of #{@cost_to} and rating of #{@rating}"
  end

  def <=>(b)
    a = self
    if a.rating < b.rating
      return -1
    elsif a.rating > b.rating
      return 1
    else
      0
    end
  end

  def ==(other)
    return false if other.nil?
    @location == other.location
  end

  def eql?(other)
    self==other
  end
end

class PrioritySet
  def initialize
    @queue = PriorityQueue.new{ |x, y| ( x <=> y) == -1 }
    @hash = {}
  end

  def push( item, rating)
    current_rating = @hash[item.location.to_s] 
    if current_rating.nil?
      @hash[item.location.to_s] = rating
      @queue.push(item, rating)
    elsif current_rating <= rating
      return
    else
      remove_item_from_queue(item)
      @hash[item.location.to_s] = rating
      @queue.push(item, rating)
    end
  end

  def pop
    item = @queue.pop
    @hash.delete(item.location.to_s)
    return item
  end

  def remove_item_from_queue(item)
    current_rating = @hash[item.location.to_s]
    temp = []
    item_to_replace = nil
    while true
      tmp_item = @queue.delete(current_rating)
      break if tmp_item.nil?
      if !(tmp_item == item)
        temp << tmp_item
      else
        item_to_replace = tmp_item
      end
    end
    temp.each do |tmp|
      #puts "Replacing #{item_to_replace} with #{item}"
      @queue.push(tmp, item.rating)
    end
  end

  def size
    @queue.size
  end

  def has_priority? p
    @queue.has_priority?(p)
  end
 
  def empty?
    @queue.empty?
  end
end

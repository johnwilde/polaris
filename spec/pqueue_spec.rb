require File.join(File.dirname(__FILE__),'helper')

describe 'priority queue' do
  before do
    @queue = PriorityQueue.new{ |x, y| (x <=> y) == -1 }
    @set = PrioritySet.new
    @splay_tree = SplayTreeMap.new
    @pe1 = PathElement.new(TwoDGridLocation.new(3,3), nil)
    @pe2 = PathElement.new(TwoDGridLocation.new(3,3), @pe1)
  end

  it "set implementation has unique keys" do
    @queue.push @pe1, 1
    @queue.push @pe2, 1
    @queue.size.should eq(2)

    @set.push @pe1, 1
    @set.push @pe2, 1 
    @set.size.should eq(1)
  end

  it "replaces existing item if identical item has lower rating" do
    @set.push @pe1, 1
    @set.push @pe2, 0
    @set.size.should eq(1)
    @set.has_priority?(0).should eq(true)
    @set.has_priority?(1).should eq(false)
  end

  it "should return lowest rated item" do 
    @set.push @pe1, 1
    @set.push @pe2, 0
    @set.pop.should eq(@pe2)
    @set.size.should eq(0)
  end
  
end

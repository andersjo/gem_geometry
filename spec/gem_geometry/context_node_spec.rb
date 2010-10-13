require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include GemGeometry

describe ContextNode do
  before(:each) do
    @context_node = ContextNode.new(:level0)
  end
  
  context '#introduce' do
    it "uses a new context in the block" do
      block_called = false
      @context_node.introduce(:embedded_context) do
        block_called = true
        @context_node.current.should be_kind_of(ContextNode)
        @context_node.current.should_not == @context_node
      end
      block_called.should be_true
    end   

    it 'delegates to current context' do
      @context_node.introduce(:level1) do
        @context_node.current.should_receive(:_introduce)
        @context_node.introduce(:level2) { }
      end
    end

    it 'allows deep nesting' do
      level1, level2  = nil
      @context_node.introduce(:level1) do
        level1 = @context_node.current
        level1.should_not == @context_node
        @context_node.introduce(:c, :level2) do
          level2 = @context_node.current
          level2.should_not == level1
        end
        @context_node.current.should == level1
      end
      @context_node.current.should == @context_node
    end
  end

  it 'solicits all_values recursively' do
    @context_node.current.values << :v0
    @context_node.introduce(:level1) do
      @context_node.current.values << :v1
    end
    @context_node.all_values.to_set.subset?(Set.new([:v0,:v1]))
  end

end


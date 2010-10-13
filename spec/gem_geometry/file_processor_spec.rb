require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include GemGeometry

describe FileProcessor do
  def given_expr(str_expr)
    sexpr = RubyParser.new.parse(str_expr)
    given_sexpr(sexpr)
  end
  
  def given_sexpr(sexpr)
    @file_processor.process(sexpr)
  end

  before(:each) do
    @file_processor = FileProcessor.new
  end

  context "Values" do
    def expect_value(value, type)
      @expect_value = value
      @expect_type = type
    end

    def expect_values(*expected)
      actual_values = @file_processor.context.all_values.map(&:value).to_set
      actual_values.should == expected.to_set
    end


    context "single values" do
      after {
        value_node = @file_processor.context.values.last
        value_node.value.should == @expect_value
        value_node.type.should  == @expect_type
      }

      it 'creates a :str value node' do
        given_expr("'quoted string'")
        expect_value("quoted string", :str)
      end

    end

    it 'extracts variable names from arglist' do
      given_expr "def m(a,b,c); end"
      expect_values :a, :b, :c
    end
  end

  context "Contexts" do
    context "new contexts" do
      def expect_context(name, type)
        new_context = @file_processor.context.children.last
        new_context.should_not be_nil
        new_context.name.should == name
        new_context.type.should == type
      end

      
      it 'method def' do
        given_expr "def method_name; end"
        expect_context :method_name, :defn
      end

      it 'class def' do
        given_expr "class Classname; end"
        expect_context :Classname, :class
      end

      it 'module def' do
        given_expr "module Classname; end"
        expect_context :Classname, :module
      end

    end
  end

  it 'should always have a default context' do
    @file_processor.context.should be_instance_of(ContextNode)
  end

  it 'should support the as_hash command' do
#    given_expr("/Users/anders/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/prettyprint.rb")
#    pp @file_processor.context.as_hash
  end


end



RSpec::Matchers.define :report_to do |boss|
  match do |employee|
    employee.reports_to?(boss)
  end

  failure_message_for_should do |employee|
    "expected the team run by #{boss} to include #{employee}"
  end
  description do
    "expected a member of the team run by #{boss}"
  end
end


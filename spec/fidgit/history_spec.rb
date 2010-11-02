require_relative 'helpers/helper'

require 'history'

module Fidgit
  class History
    class Maths < Action
      def initialize(value)
        @value = value
      end
    end

    class Add < Maths
      def do
        $x += @value
      end

      def undo
        $x -= @value
      end
    end

    class Sub < Maths
      def do
        $x -= @value
      end

      def undo
        $x += @value
      end
    end
  end

  describe History do
    before :each do
      $x = 0 # Used as target of test action.
      @object = described_class.new
    end

    describe "initialize()" do
      it "should produce an object that is not undoable or redoable" do
        @object.can_undo?.should be_false
        @object.can_redo?.should be_false
      end
    end

    describe "do()" do
      it "should raise an error if the parameter is incorrect" do
        lambda { @object.do(12) }.should raise_error ArgumentError
      end

      it "should perform the action's do() method correctly" do
        @object.do(History::Add.new(2))

        $x.should == 2
        @object.can_undo?.should be_true
        @object.can_redo?.should be_false
      end
    end

    describe "undo()" do
      it "should raise an error if there is nothing to undo" do
        lambda { @object.undo }.should raise_error
      end

      it "should perform the undo method on the action" do
        @object.do(History::Add.new(2))
        @object.undo

        $x.should == 0
        @object.can_undo?.should be_false
        @object.can_redo?.should be_true
      end
    end

    describe "redo()" do
      it "should raise an error if there is nothing to redo" do
        lambda { @object.redo }.should raise_error
      end

      it "should perform the undo method on the action" do
        @object.do(History::Add.new(2))
        @object.undo
        @object.redo

        $x.should == 2
        @object.can_undo?.should be_true
        @object.can_redo?.should be_false
      end
    end

    describe "replace_last()" do
      it "should raise an error if there is nothing to redo" do
        lambda { @object.replace_last(12) }.should raise_error ArgumentError
      end

      it "should raise an error if there is nothing to replace" do
        lambda { @object.replace_last(History::Add2.new) }.should raise_error
      end

      it "should correctly replace the last action" do
        @object.do(History::Add.new(2))
        @object.replace_last(History::Sub.new(1))

        $x.should == -1
        @object.can_redo?.should be_false
        @object.can_undo?.should be_true
      end

      it "should not remove redoable actions" do
        @object.do(History::Add.new(2))
        @object.do(History::Add.new(8))
        @object.undo
        @object.replace_last(History::Sub.new(1))

        $x.should == -1
        @object.can_redo?.should be_true
        @object.can_undo?.should be_true

        @object.redo
        $x.should == 7
      end
    end

    # Abstract class, so doesn't really do anything.
    describe History::Action do
      before :each do
        @object = described_class.new
      end

      describe "do()" do
        it "should raise an error" do
          lambda { @object.do }.should raise_error NotImplementedError
        end
      end

      describe "undo()" do
        it "should raise an error" do
          lambda { @object.undo }.should raise_error NotImplementedError
        end
      end
    end
  end
end

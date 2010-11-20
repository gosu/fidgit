require_relative 'helpers/helper'

require 'event'

module Fidgit
  describe Event do
    before :each do
      class Test
        include Event
      end
    end

    after :each do
      Fidgit.send :remove_const, :Test
    end

    subject { Test }

    describe "events" do
      it "should initially be empty" do
        subject.events.should be_empty
      end
    end

    describe "event" do
      it "should add the event to the list of events handled" do
        subject.event :frog
        subject.events.should include :frog
      end

      it "should inherit parent's events and be able to add more" do
        Test.event :frog
        class Test2 < Test; end
        Test2.event :fish
        Test2.events.should include :frog
        Test2.events.should include :fish
      end
    end

    context "When included into a class that is instanced" do
      subject { Test.event :frog; Test.new }

      describe "#subscribe" do
        it "should add a handler as a block" do
          subject.subscribe(:frog) { puts "hello" }
        end

        it "should fail if the event name isn't handled by this object" do
          ->{ subject.subscribe(:unhandled_event) {} }.should raise_error ArgumentError
        end

        it "should add a handler as a method" do
          subject.stub! :handler
          subject.subscribe(:frog, subject.method(:handler))
        end

        it "should fail if neither a method or a block is passed" do
          ->{ subject.subscribe(:frog) }.should raise_error ArgumentError
        end

        it "should fail if both a method and a block is passed" do
          subject.stub! :handler
          ->{ subject.subscribe(:frog, subject.method(:handler)) { } }.should raise_error ArgumentError
        end
      end

      describe "#publish" do
        it "should return nil if there are no handlers" do
          subject.publish(:frog).should be_nil
        end

        it "should return nil if there are no handlers that handle the event" do
          subject.should_receive(:frog).with(subject)
          subject.should_receive(:handler).with(subject)
          subject.subscribe(:frog, subject.method(:handler))
          subject.publish(:frog).should be_nil
        end

        it "should return :handled if a manual handler handled the event and not call other handlers" do
          subject.should_not_receive(:handler1)
          subject.should_receive(:handler2).with(subject).and_return(:handled)
          subject.subscribe(:frog, subject.method(:handler1))
          subject.subscribe(:frog, subject.method(:handler2))
          subject.publish(:frog).should == :handled
        end

        it "should return :handled if an automatic handler handled the event and not call other handlers" do
          subject.should_receive(:frog).with(subject).and_return(:handled)
          subject.should_not_receive(:handler2)
          subject.subscribe(:frog, subject.method(:handler2))
          subject.publish(:frog).should == :handled
        end

        it "should pass the object as the first parameter" do
          subject.should_receive(:handler).with(subject)
          subject.subscribe(:frog, subject.method(:handler))
          subject.publish :frog
        end

        it "should call all the handlers, once each" do
          subject.should_receive(:handler1).with(subject)
          subject.should_receive(:handler2).with(subject)
          subject.subscribe(:frog, subject.method(:handler1))
          subject.subscribe(:frog, subject.method(:handler2))
          subject.publish(:frog).should be_nil
        end

        it "should pass parameters passed to it" do
          subject.should_receive(:handler).with(subject, 1, 2)
          subject.subscribe(:frog, subject.method(:handler))
          subject.publish(:frog, 1, 2).should be_nil
        end

        it "should only call the handlers requested" do
          Test.event :fish

          subject.should_receive(:handler1).with(subject)
          subject.should_not_receive(:handler2)
          subject.subscribe(:frog, subject.method(:handler1))
          subject.subscribe(:fish, subject.method(:handler2))
          subject.publish(:frog).should be_nil
        end

        it "should automatically call a method on the publisher if it exists" do
          subject.should_receive(:frog).with(subject)
          subject.publish(:frog).should be_nil
        end

        it "should fail if the event name isn't handled by this object" do
          ->{ subject.publish(:unhandled_event) }.should raise_error ArgumentError
        end
      end
    end
  end
end
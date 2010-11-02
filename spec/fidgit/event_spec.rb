require_relative 'helpers/helper'

require 'event'

module Fidgit
  describe Event do
    subject { Object.new.extend described_class }

    describe "#subscribe" do
      it "should add a handler as a block" do
        subject.subscribe(:frog) { puts "hello" }
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

      it "should not call any more handlers if one returns :handled" do
        subject.should_receive(:handler1).with(subject).and_return(:handled)
        subject.should_not_receive(:handler2)
        subject.subscribe(:frog, subject.method(:handler1))
        subject.subscribe(:frog, subject.method(:handler2))
        subject.publish(:frog).should == :handled
      end

      it "should return :handled if a manual handler handled the event and not call other handlers" do
        subject.should_receive(:handler1).with(subject).and_return(:handled)
        subject.should_not_receive(:handler2)
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
    end
  end
end
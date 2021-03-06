require_relative 'helpers/helper'

require 'redirector'

include Fidgit

describe RedirectorMethods do
  describe "::Object" do
    subject { Object.new }

    describe '#instance_methods_eval' do
      it "should fail if a block is not provided" do
         ->{ subject.instance_methods_eval }.should raise_error
      end

     it "should yield the target" do
        subject.instance_methods_eval { |target| @frog = target }
        @frog.should equal subject
      end

      it "should allow ivars to be read from the calling context" do
        @frog = 5
        fish = 0
        subject.instance_methods_eval { fish = @frog }
        fish.should equal 5
      end

      it "should allow ivars to be written to the calling context" do
        subject.instance_methods_eval { @frog = 10 }
        @frog.should equal 10
      end

      it "should not allow access to ivars in the subject" do
        subject.instance_variable_set :@frog, 5
        fish = 0
        subject.instance_methods_eval { fish = @frog }
        fish.should be_nil
      end

      it "should allow access to methods in the subject" do
        subject.should_receive(:frog)
        subject.instance_methods_eval { frog }
      end

      it "should allow stacked calls" do
        object1 = Object.new
        should_not_receive :frog
        object1.should_not_receive :frog
        subject.should_receive :frog

        object1.instance_methods_eval do
          subject.instance_methods_eval do
            frog
          end
        end
      end

      it "should fail if method does not exist on the subject or context" do
        ->{ subject.instance_methods_eval { frog } }.should raise_error NameError
      end

      it "should call the method on the context, if it doesn't exist on the subject" do
        should_receive(:frog)
        subject.instance_methods_eval { frog }
      end

      [:public, :protected, :private].each do |access|
        it "should preserve #{access} access for methods redirected on the context" do
          class << self; def frog; end; end
          (class << self; self; end).send access, :frog
          subject.should_receive :frog
          subject.instance_methods_eval { frog }
          (send "#{access}_methods").should include :frog
        end
      end
    end
  end
end
require_relative 'helpers/helper'

require 'fidgit'

require 'yaml'

DEFAULT_SCHEMA_FILE_NAME = File.expand_path(File.join(__FILE__, '..', 'schema_test.yml'))

include Fidgit

describe Schema do
  subject { Schema.new(Hash.new) }

  context "given the default schema" do
    subject { Schema.new(YAML.load(File.read(DEFAULT_SCHEMA_FILE_NAME))) }

    describe "#color" do
      it "should have the color :none" do
        subject.color(:none).should eq Gosu::Color.rgba(0, 0, 0, 0)
      end

      it "should have the color :white" do
        subject.color(:white).should eq Gosu::Color.rgb(255, 255, 255)
      end

      it "should not have the color :sky_blue_pink" do
        subject.color(:sky_blue_pink).should be_nil
      end
    end

    describe "#constant" do
      it "should have the constant :scroll_bar_thickness" do
        subject.constant(:scroll_bar_thickness).should equal 12
      end

      it "should have the constant :moon_cow_height" do
        subject.constant(:moon_cow_height).should be_nil
      end
    end

    describe "#default" do
      it "should fail if the class given is not an Element" do
        ->{ subject.default(String, :frog) }.should raise_error ArgumentError
      end

      it "should fail if the value is not ever defined" do
        ->{ subject.default(Element, :knee_walking_turkey) }.should raise_error
      end

      it "should give the correct value for a defined color" do
        subject.default(Element, :color).should eq Gosu::Color.rgb(255, 255, 255)
      end

      it "should give the symbol name if the value is one" do
        subject.default(Element, :align_h).should be :left
      end

      it "should give the correct value for a defined constant" do
        subject.default(VerticalScrollBar, :width).should equal 12
      end

      it "should give the correct value for a color defined in an ancestor class" do
        subject.default(Label, :color).should eq Gosu::Color.rgb(255, 255, 255)
      end

      it "should give the correct value for a defined nested value" do
        subject.default(Button, [:disabled, :background_color]).should eq Gosu::Color.rgb(50, 50, 50)
      end

      it "should give the outer value for an undefined nested value" do
        subject.default(Element, [:hover, :color]).should eq Gosu::Color.rgb(255, 255, 255)
      end
    end
  end
end
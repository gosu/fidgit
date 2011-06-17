require_relative "helpers/helper"

include Fidgit

describe Label do
  before :all do
    $window = Chingu::Window.new(100, 100, false) unless $window
  end

  context "with default parameters" do
    subject { Label.new( "Hello world!") }

    it "should have text value set" do
      subject.text.should eq "Hello world!"
    end

    it "should have white text" do
      subject.color.should eq Gosu::Color.rgb(255, 255, 255)
    end

    it "should have a transparent background" do
      subject.background_color.should be_transparent
    end

    it "should have a transparent border" do
      subject.border_color.should be_transparent
    end

    it "should be enabled" do
      subject.should be_enabled
    end

    it "should not have an image" do
      subject.icon.should be_nil
    end
  end
end
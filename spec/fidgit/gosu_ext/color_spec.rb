require_relative "helpers/helper"

include Gosu

describe Color do
  describe "rgb" do
    it "should create a color with the correct values from channel values" do
      color = Color.rgb(1, 2, 3)
      color.red.should equal 1
      color.green.should equal 2
      color.blue.should equal 3
      color.alpha.should equal 255
    end
  end

  describe "rgba" do
    it "should create a color with the correct value from channel valuess" do
      color = Color.rgba(1, 2, 3, 4)
      color.red.should equal 1
      color.green.should equal 2
      color.blue.should equal 3
      color.alpha.should equal 4
    end
  end

  describe "argb" do
    it "should create a color with the correct values from channel values" do
      color = Color.argb(1, 2, 3, 4)
      color.red.should equal 2
      color.green.should equal 3
      color.blue.should equal 4
      color.alpha.should equal 1
    end
  end

  describe "from_tex_play" do
    it "should create a color with the correct values" do
      color = Color.from_tex_play([1 / 255.0, 2 / 255.0, 3 / 255.0, 4 / 255.0])
      color.red.should equal 1
      color.green.should equal 2
      color.blue.should equal 3
      color.alpha.should equal 4
    end
  end

  describe "#to_tex_play" do
    it "should create an array with the correct values" do
      array = Color.rgba(1, 2, 3, 4).to_tex_play
      array.should eq [1 / 255.0, 2 / 255.0, 3 / 255.0, 4 / 255.0]
    end
  end

  describe "#==" do
    it "should return true for colours that are identical" do
      (Color.rgb(1, 2, 3) == Color.rgb(1, 2, 3)).should be_true
    end

    it "should return false for colours that are not the same" do
      (Color.rgb(1, 2, 3) == Color.rgb(4, 2, 3)).should be_false
    end
  end

  describe "#transparent?" do
    it "should be true if alpha is 0" do
      Color.rgba(1, 1, 1, 0).should be_transparent
    end

    it "should be fa;se if alpha is > 0" do
      Color.rgba(1, 1, 1, 2).should_not be_transparent
    end
  end
end
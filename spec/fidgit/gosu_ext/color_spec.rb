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

  describe "ahsv" do
    it "should create a color with the correct values from channel values" do
      color = Color.ahsv(1, 180.0, 0.5, 0.7)
      color.hue.should be_within(0.001).of(180.0)
      color.saturation.should be_within(0.01).of(0.5)
      color.value.should be_within(0.01).of(0.7)
      color.alpha.should equal 1
    end
  end

  describe "hsva" do
    it "should create a color with the correct values from channel values" do
      color = Color.hsva(180.0, 0.5, 0.7, 4)
      color.hue.should be_within(0.001).of(180.0)
      color.saturation.should be_within(0.01).of(0.5)
      color.value.should be_within(0.01).of(0.7)
      color.alpha.should equal 4
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

    it "should be false if 0 > alpha > 255" do
      Color.rgba(1, 1, 1, 2).should_not be_transparent
    end

    it "should be false if alpha == 255" do
      Color.rgba(1, 1, 1, 255).should_not be_transparent
    end
  end

  describe "#opaque?" do
    it "should be true if alpha is 0" do
      Color.rgba(1, 1, 1, 0).should_not be_opaque
    end

    it "should be false if 0 > alpha > 255" do
      Color.rgba(1, 1, 1, 2).should_not be_opaque
    end

    it "should be false if alpha == 255" do
      Color.rgba(1, 1, 1, 255).should be_opaque
    end
  end

  describe "#+" do
    it "should add two colours together" do
      (Color.rgba(1, 2, 3, 4) + Color.rgba(10, 20, 30, 40)).should == Color.rgba(11, 22, 33, 44)
    end

    it "should cap values at 255" do
      (Color.rgba(56, 56, 56, 56) + Color.rgba(200, 200, 200, 200)).should == Color.rgba(255, 255, 255, 255)
    end
  end

  describe "#-" do
    it "should subtract one color from another two colours together" do
      (Color.rgba(10, 20, 30, 40) - Color.rgba(1, 2, 3, 4)).should == Color.rgba(9, 18, 27, 36)
    end

    it "should cap values at 0" do
      (Color.rgba(56, 56, 56, 56) - Color.rgba(57, 57, 57, 57)).should == Color.rgba(0, 0, 0, 0)
    end
  end
end
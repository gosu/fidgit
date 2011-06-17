require_relative 'helpers/helper'
require_relative 'helpers/tex_play_helper'

require 'fidgit'

def check_thumbnail_is_square
  {square: [10, 10], tall: [5, 12], wide: [6, 5]}.each_pair do |type, dimensions|
    context "with a #{type} image" do
      it "should be square and just large enough to contain the image" do
        subject = described_class.new(Gosu::Image.create(*dimensions), thumbnail: true)
        subject.width.should equal dimensions.max
        subject.height.should equal dimensions.max
      end
    end
  end
end

def check_image_dimensions
  {square: [10, 10], tall: [5, 12], wide: [6, 5]}.each_pair do |type, dimensions|
    context "with a #{type} image" do
      it "should be just large enough to contain the image" do
        subject = described_class.new(Gosu::Image.create(*dimensions))
        subject.width.should equal dimensions.first
        subject.height.should equal dimensions.last
      end
    end
  end
end

module Fidgit
  describe ImageFrame do
    before :all do
      $window = Chingu::Window.new(100, 100, false) unless $window
    end

    before :each do
      @image = Gosu::Image.create(10, 10)
    end

    subject { described_class.new(@image) }

    describe '#image' do
      it "should have the image set" do
        subject.image.should be @image
      end
    end

    describe '#width and #height' do
      check_image_dimensions
    end

    describe "Thumbnails" do
      subject { described_class.new(@image, thumbnail: true) }

      describe '#image=' do
        it "should update the height and width" do
          image = Gosu::Image.create(8, 2)
          subject.image = image
          subject.height.should equal 8
          subject.width.should equal 8
        end
      end

      describe '#width and #height' do
        check_thumbnail_is_square
      end
    end
  end
end
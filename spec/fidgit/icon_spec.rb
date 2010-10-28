require_relative 'helpers/helper'

require 'fidgit/gosu_ext'
require 'texplay'
include Gosu

require 'fidgit/icon'

def check_icon_is_square(dimension)
  [[10, 10], [5, 12], [6, 5]].each do |size|
    context "with an image of size #{size}" do
      subject { described_class.new(Image.create(*size)).send dimension }
      it { should equal size.max }
    end
  end
end

module Fidgit
  describe Icon do
    before :all do
      $window = Gosu::Window.new(100, 100, false)
      @image = Image.create(10, 10)
    end

    subject { Icon.new(@image) }

    describe '#image' do
      it "should have the image set" do
        subject.image.should be @image
      end
    end

    describe '#image=' do
      it "should update the height and width" do
        image = Image.create(8, 2)
        subject.image = image
        subject.height.should equal 8
        subject.width.should equal 8
      end
    end

    describe '#width' do
      check_icon_is_square :width
    end

    describe '#height' do
      check_icon_is_square :height
    end
  end
end
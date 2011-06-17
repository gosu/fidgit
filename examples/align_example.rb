require_relative 'helpers/example_window'

# Change font and labels in the schema.
Fidgit::Element.schema.merge_elements!(Element: { font_height: 24 }, Label: { background_color: "?dark_blue" })

class ExampleState < Fidgit::GuiState
  ROW_BACKGROUND = Gosu::Color.rgb(0, 100, 0)
  CELL_BACKGROUND = Gosu::Color.rgb(100, 0, 0)
  OUTER_BACKGROUND = Gosu::Color.rgb(100, 0, 100)

  def initialize
    super

    vertical align: :center, background_color: OUTER_BACKGROUND do
      label "h => align_h, v => align_v", align_h: :center

      grid num_columns: 4, align: :center, cell_background_color: CELL_BACKGROUND, background_color: ROW_BACKGROUND do
        label "xxx"
        label "h fill", align_h: :fill
        label "h right", align_h: :right
        label "h center", align_h: :center


        vertical do
          label "xxx"
          label "xxx"
        end
        label "v fill", align_v: :fill
        label "v center", align_v: :center
        label "v bottom", align_v: :bottom

        vertical align_h: :center do
          label "h center"
          label "h center"
        end
        label "top right", align: [:top, :left]
        label "bottom left", align_h: :left, align_v: :bottom
        label "h/v fill", align: :fill

        label ""
        label "bottom right", align_h: :right, align_v: :bottom
        label "bottom center", align_h: :center, align_v: :bottom
        vertical align_h: :right do
          label "h right"
          label "h right"
        end

        label "Blah, bleh!"
        label "Yada, yada, yada"
        label "Bazingo by jingo!"
      end
    end
  end
end

ExampleWindow.new.show
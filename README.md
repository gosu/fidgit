Fidgit
======

Fidgit is a GUI framework built on [Gosu](http://libgosu.org/) and [Chingu](http://ippa.se/chingu)


Description
-----------

The API is inspired by [Shoes](http://shoesrb.com/), but since Shoes is very simplistic, the level of functionality is
based around [FXRuby](http://www.fxruby.org/) and other GUI APIs.
Fidgit was originally developed as a part of the Sidney game, but as it got more complex, it was obvious it would be
useful to separate them.

_WARNING: THIS PROJECT IS IN EARLY ALPHA DEVELOPMENT AND THE API IS LIABLE TO CONTINUOUS CHANGE AND IT IS QUITE UNSTABLE!_

Read the Yard documentation at [rubydoc.info](http://rubydoc.info/github/Spooner/fidgit/master)


Aim
---

Fidgit aims to be a toolkit which will provide the building blocks to quickly create a GUI either for a GUI-based game
or for options screens and menus within a regular Gosu game.


License
-------

MIT (see COPYING.txt)


Requirements
------------

* Ruby 1.9.2 or higher.
* Gosu gem 0.7.27.1
  * [Installing Gosu dependencies on Linux](http://code.google.com/p/gosu/wiki/GettingStartedOnLinux) (On Win32 and OS X there are binary gems available)
* Chingu gem 0.9rc4.


Example
-------

```ruby
# examples/readme_example.rb
require 'fidgit'

class MyGame < Chingu::Window
  def initialize
    super(640, 480, false)

    # To use the Fidgit features, a Fidgit::GuiState must be active.
    push_game_state MyGuiState
  end
end

class MyGuiState < Fidgit::GuiState
  def initialize
    super

    # Create a vertically packed section, centred in the window.
    vertical align: :center do
      # Create a label with a dark green background.
      my_label = label "Hello world!", background_color: Gosu::Color.rgb(0, 100, 0)

      # Create a button that, when clicked, changes the label.
      button("Goodbye", align_h: :center, tip: "Press me and be done with it!") do
        my_label.text = "Goodbye cruel world!"
      end
    end
  end
end

MyGame.new.show
```


API
---

As well as a cursor and tool-tips that are managed by the GuiState for you, there are several elements you can use inside your GuiState.

Elements are best added by using simple methods (listed below). Most of these method accept a block, some offering access to public methods of the element and others being default event handlers.

The GuiState itself only accepts #vertical/#horizontal/#grid, but any packer or group accepts any other element method.


GuiState methods
----------------

* `pack([:vertical|:horizontal|:grid], ...)` - Add a packer to the state (Block has access to public methods).
* `clear()` - remove any packers added to the state.
* `menu(...)` - Show a context menu (Block has access to public methods).
  * `item(text, value, ...)` - Item in a menu (Block handles :clicked_left_mouse_button event).
  * `separator(...)` - A horizontal separator between menu items.
* `message(text, ...)` - Show a message box with button(s) (Block subscribes to a button getting clicked).
* `file_dialog([:open, :save], ...)` - Open a file dialog to load or save a file (Block is passed the button pressed and the file path set).

### Container methods

#### Arrangement managers

Fidgit uses automatic packers to manage layout.

* `pack([:vertical|:horizontal|:grid], ...)` - Packer that packs its component elements (Block has access to public methods).
* `group(...)` - Manages any groupable elements put inside it, such as radio-buttons (Block has access to public methods). Best to subscribe to :changed event handler.
* `scroll_window(...)` - A window having content larger than what is shown, scrolled with scroll-bars (Block has access to public methods of the contents packer)

#### Elements

Elements can be placed inside a packer or group.

* `button(text, ...)` - Button with text and/or icon (Block handles :clicked_left_mouse_button event).
* `color_picker(...)` - Red, green and blue sliders and colour indicator (Block handles :changed event).
* `image_frame(image, ...)` - Wrapper around a Gosu::Image to embed it in the GUI.
* `label(text, ...)` - Label with text and, optionally, an icon (No block accepted).
* `slider(...)` - Horizontal slider with handle (Block handles :changed event).
* `text_area(...)` - An multi-line element, containing editable text (Block handles :changed event).
* `toggle_button(text, ...)` - Button that can be toggled on/off (Block handles :changed event).

##### Groupable elements

These should be placed within a group (directly or indirectly) and only one of them will be selected. The group manages which one is selected.

* `color_well(color, ...)` - A radio-button used to pick a colour (Block handles :clicked_left_mouse_button event).
* `radio_button(text, value, ...)` - Button that is part of a group (Block handles :clicked_left_mouse_button event).

##### Compound elements

These elements contain items, which can easily be added from within a block passed to them. One can subscribe to the :changed event, which is usually easier than managing each item separately.

* `combo_box(...)` - Button that has a drop-down menu attached (Block has access to public methods).
  * `item(text, value, ...)` - Add an item to a combo box (Block handles :clicked_left_mouse_button event).
* `list(...)` - A vertical list of items to select from (Block has access to public methods).
  * `item(text, value, ...)` - Add an item to a combo box (Block handles :clicked_left_mouse_button event).


##### Alternative GUI frameworks

There are two other GUI tool-kits that work with Gosu:

* [Rubygoo](http://code.google.com/p/rubygoo/)
  * Additionally supports [Rubygame](http://rubygame.org/) (as well as Gosu).
  * Only simple widgets are implemented.
  * No longer supported.

* [GGLib](http://code.google.com/p/gglib/) (Gosu GUI Library)
  * Pretty graphical themes.
  * Only simple widgets are implemented.
  * No longer supported (though author has commented that they would like to pick it up again).

Remember that if you primarily want a GUI for your GUI application, not just a GUI in your Gosu game, consider using a dedicated GUI tool-kit, such as [Shoes](http://shoesrb.com/) or [wxruby-ruby19](http://wxruby.rubyforge.org/)

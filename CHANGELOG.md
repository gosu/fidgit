Fidgit changelog
================

v0.2.3
------

* Exposed #handle accessor for Slider.
* Made Slider accept being disabled.
* Made Slider handle show tip.

v0.2.2
------

* Prevented ToggleButton border colour changing.
* More careful about stripping out html tags in TextArea.

v0.2.1
------

* Added: Click in ScrollBar gutter to scroll window by height/width of view window.
* Added: Click and drag to select text in enabled TextArea.
* Fixed: Color changes on disabling buttons.

v0.2.0
------

* Added editable attribute to TextArea (Allows selection, but not alteration).
* Added Element#font= and :font option.
* Added Gosu::Color#colorize to use when using in-line text styling.
* Managed layout of entities and XML tags (Used by Gosu) in TextArea text better (tags still don't like newlines inside them).
* Changed license from LGPL to MIT.
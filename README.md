# CMST-Cubemap-switcher-or-Responsive-cubemaps
https://steamcommunity.com/sharedfiles/filedetails/?id=2901811539

Requires Referenced map files listener addon to work!
(https://steamcommunity.com/workshop/filedetails/?id=969978989)

What is this?

Cubemap switcher is an addon that allows you to create function for your map, that dynamically switches cubemaps then light entities toggle on and off.
This is a tool for map makers.

How to use it?

You can follow in-game guide by typing "cubemap_switcher_help" into console or follow a guide below
Before you continue, see method below this one and choose the best from these for your map.

Method 1

To begin, start new game on your map, then..
Step 1: Turn off all the lights.
 You must turn off all switchable lights on your map, use 'cubemap_switcher_turnlights 0' to do this
Step 2: Bake unlit cubemaps.
 Bake your cubemaps now, use 'buildcubemaps'
Step 3: Extract unlit cubemaps.
 Extract your cubemaps, use 'cubemap_switcher_writecubemaps' and follow instructions written in the chat after it finishes extraction. Your game mast be un-paused.
Step 4: Bake default cubemaps.
 Restart the map, then turn on all switchable lights on your map, use 'cubemap_switcher_turnlights 1' to do this. Then bake cubemaps, use 'buildcubemaps'.
Step 5: Get the function.
 Restart the map again and then use 'cubemap_switcher_getfunction'(you can add 1 as an argument here if you're sure the map you're working on is going to be played only then CMST installed, otherwise, if you'll leave this argument blank, you'll get a standalone function*) and follow instructions written in the chat after it finishes.
Don't forget to restart your game after all this.
After you've done everything, your map will NOT require this addon to be installed and required addon for this addon*.

Props still shine like sun then lights turn off

Unfortunately, CMST can't change envmap lightning on props and other non-brush entities. BUT... you can use next method to kinda get around this restriction.

Method 2

In this method you'll need to bake cubemaps(for your final map, not the function) while all lights are turned off.
The game will render unlit cubemaps on all props and other non-brush entities.

If your cubemaps aren't already baked with all lights turned on(They most likely are baked lit so skip this maybe) then..
Step 1: Turn on all the lights.
  You must turn on all switchable lights on your map, use 'cubemap_switcher_turnlights 1' to do this
Step 2: Bake lit cubemaps.
  Bake your cubemaps now, use 'buildcubemaps'
Else skip these steps..

Step 3: Extract lit cubemaps.
 Extract your cubemaps, use 'cubemap_switcher_writecubemaps' and follow instructions written in the chat after it finishes extraction. Your game mast be un-paused.

Step 4: Turn off all the lights.
 Restart the map(If followed steps 1-2), then you must turn off all switchable lights on your map, use 'cubemap_switcher_turnlights 0' to do this
Step 5: Bake unlit cubemaps.
 Bake your cubemaps now, use 'buildcubemaps', these must be your map's default cubemaps from now on

Step 6: Get inverted function.
 Restart the map again and then use 'cubemap_switcher_getfunction_inverted' and follow instructions written in the chat after it finishes. 
After you've done everything, your map will NOT require this addon to be installed and required addon for this addon*.

If you still have any questions, you can ask them in the discussions or in the comments

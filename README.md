# CMST-Cubemap-switcher-or-Responsive-cubemaps
https://steamcommunity.com/sharedfiles/filedetails/?id=2901811539

Requires Referenced map files listener addon to work!
(https://steamcommunity.com/workshop/filedetails/?id=969978989)

[h1]What is this?[/h1]

[h2]Cubemap switcher is an addon that allows you to create function for your map, that dynamically switches cubemaps then light entities toggle on and off.
This is a tool for map makers.[/h2]

[h1]How to use it?[/h1]

[h2]You can follow in-game guide by typing "cubemap_switcher_help" into console or follow a guide below[/h2]
[h2]Before you continue, see method below this one and choose the best from these for your map.[/h2]

[h3]Method 1[/h3]

[b]To begin, start new game on your map, then..[/b]
[b]Step 1: Turn off all the lights.[/b]
 You must turn off all switchable lights on your map, use 'cubemap_switcher_turnlights 0' to do this
[b]Step 2: Bake unlit cubemaps.[/b]
 Bake your cubemaps now, use 'buildcubemaps'
[b]Step 3: Extract unlit cubemaps.[/b]
 Extract your cubemaps, use 'cubemap_switcher_writecubemaps' and follow instructions written in the chat after it finishes extraction. Your game mast be un-paused.
[b]Step 4: Bake default cubemaps.[/b]
 Restart the map, then turn on all switchable lights on your map, use 'cubemap_switcher_turnlights 1' to do this. Then bake cubemaps, use 'buildcubemaps'.
[b]Step 5: Get the function.[/b]
 Restart the map again and then use 'cubemap_switcher_getfunction'(you can add 1 as an argument here if you're sure the map you're working on is going to be played only then CMST installed, otherwise, if you'll leave this argument blank, you'll get a standalone function*) and follow instructions written in the chat after it finishes.
Don't forget to restart your game after all this.
[b]After you've done everything, your map will NOT require this addon to be installed and required addon for this addon*.[/b]

[h1]Props still shine like sun then lights turn off[/h1]

[h2]Unfortunately, CMST can't change envmap lightning on props and other non-brush entities. BUT... you can use next method to kinda get around this restriction.[/h2]

[h3]Method 2[/h3]

[b]In this method you'll need to bake cubemaps(for your final map, not the function) while all lights are turned off.[/b]
[b]The game will render unlit cubemaps on all props and other non-brush entities.[/b]

[b]If your cubemaps aren't already baked with all lights turned on(They most likely are baked lit so skip this maybe) then..[/b]
 [b]Step 1: Turn on all the lights.[/b]
  You must turn on all switchable lights on your map, use 'cubemap_switcher_turnlights 1' to do this
 [b]Step 2: Bake lit cubemaps.[/b]
  Bake your cubemaps now, use 'buildcubemaps'
[b]Else skip these steps..[/b]

[b]Step 3: Extract lit cubemaps.[/b]
 Extract your cubemaps, use 'cubemap_switcher_writecubemaps' and follow instructions written in the chat after it finishes extraction. Your game mast be un-paused.

[b]Step 4: Turn off all the lights.[/b]
 Restart the map(If followed steps 1-2), then you must turn off all switchable lights on your map, use 'cubemap_switcher_turnlights 0' to do this
[b]Step 5: Bake unlit cubemaps.[/b]
 Bake your cubemaps now, use 'buildcubemaps', these must be your map's default cubemaps from now on

[b]Step 6: Get inverted function.[/b]
 Restart the map again and then use 'cubemap_switcher_getfunction_inverted' and follow instructions written in the chat after it finishes. 
[b]After you've done everything, your map will NOT require this addon to be installed and required addon for this addon*.[/b]

[h1]If you still have any questions, you can ask them in the discussions or in the comments[/h1]

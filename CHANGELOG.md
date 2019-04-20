# Version 0.17.0.1766 - 2019-04-20

## Additions
- Added simple base screen.
    - Allows the player to start a new mission.
    - Allows the player to quit to the main menu.
    - Allows the player to recruit new stalkers.
    - Allows the player to edit each stalkers inventory and to store items in the base.
    - Allows the player to sell and buy items inside of a shop menu.
    - Starting a new game will direct the player directly to the base screen.
    - Shows overview over the player's faction.
    - Missions can be aborted and the game will return back to the base screen.
- Added button to the option menu which allows opening the save / modding directory.
- Added keybinding that centers the camera on the currently selected character.
- Added better save game validation.
- Added sorting mechanics for paginated lists.
- Added keybindings for the "split item stack" and "drag full item stack" actions so they can be changed.

## Fixes
- Fixed inventory volume being set incorrectly after loading a savegame.
- Fixed health points being set incorrectly after loading a savegame.
- Fixed items of paginated list not being moved correctly when the paginated list was moved.
- Fixed positioning of UI child elements.
- Fixed splitting of item stacks.

## Other Changes
- Changed view range based on character classes.
- Changed values for shooting and throwing skills based on character classes.
- Changed prefab editor to be more performant.
- Changed translator to load translations from a single .lua file.
- Changed translator to load external translations.
- Changed savegame screen
    - Saves are now displayed as a paginated list for easy navigation
    - Saves can now be deleted by clicking on the "X" button
    - Improved information about saves
- Changed all items to be stackable.
    - Item stacks are now merged automatically.
- Changed detection for mouse dragging events which makes it easier to distinguish dragging events from normal mouse clicking.




# Version 0.16.1.1627 - 2018-09-02 (LÖVE 11.1)

## Additions
- Added support for latin-1 charset.

## Fixes
- Fixed camera focusing on the wrong character when switching from the current to the previous character.
- Fixed faulty loading of world objects.
- Fixed faulty loading of characters.

## Other Changes
- Changed how fonts are loaded by the game to support different charsets.




# Version 0.16.0.1615 - 2018-08-30 (LÖVE 11.1)

## Additions
- Added paginated list UIElement.
    - Replaced old keybinding list with new paginated lists.
    - Replaced selectors in prefab editor with new paginated lists.
- Added keybinding layouts to allow different bindings for the same key based on the game's context.
- Added title to the keybinding screen.
- Added selector for canvas sizes on prefab editor screen.
- Added proper re-bindable controls for the prefab editor.
- Added automatic camera tracking of moving characters (previously removed in 0.15.0.1521).
- Added automatic camera movement when selecting a different character (previously removed in 0.15.0.1521).
- Added class-based action point values.

## Removals
- Removed action to open health panel for enemy and neutral characters.

## Fixes
- Fixed huge performance issue with menu titles (especially noticeable on older systems).
- Fixed crash after winning the game because the game tried to switch to the removed base screen.
- Fixed tile info revealing stats of enemy characters which aren't visible to the player's characters.
- Fixed rebinding of unassigned actions.
- Fixed issue where equipment and inventory list weren't clearing their children properly.
- Fixed right-click operation on inventory screen.
- Fixed scroll bar for item description on inventory screen.
- Fixed FOV not updating when a world object is opened.
- Fixed flood filling tool in prefab editor.
- Fixed camera scrolling on prefab editor screen.
- Fixed faulty camera bounds after loading a prefab on prefab editor screen.
- Fixed message log retaining old messages.

## Other Changes
- Changed targeted LÖVE version to 11.1 "Mysterious Mysteries".
- Changed data structure of the game's combat map.
- Changed FOV checks to be more efficient.
    - Checking wether a faction can see a specific tile is roughly five times faster than before.
    - Checking wether a character can see a specific tile is roughly three times as fast now.
- Changed tile info to be more efficient by only updating it when necessary.
- Changed world object hit points to fit the current weapon damage values.
- Changed buttons in prefab editor to use correct icon colors.
- Changed cursor in prefab editor to use icon and color of selected sprite.
- Changed map editor to be visible in the main menu by default.
- Changed map editor to start in prefab instead of layout editor mode.




# Version 0.15.0.1521 - 2018-07-27 (LÖVE 11.0)

## Additions
- Added functionality for saving log files to a folder in the safe directory when the game crashes.

## Fixes
- Fixed sprites not showing for connectable world objects in the map editor.
- Fixed camera panning not working on the map editor's map testing screen.
- Fixed crash caused by weapon stacks in the inventory screen.

## Removals
- Removed automatic camera tracking of moving characters (will be re-implemented in future versions).
- Removed automatic camera movement when selecting a different character (will be re-implemented in future versions).
- Removed hardcoded strings from help screen.

## Other Changes
- Changed targeted LÖVE version to 11.0 "Mysterious Mysteries".
- Changed the way audio sources are loaded, stored and played.
- Changed speed and transparency of pulsating overlays (movement paths, hit cones, ...).
- Changed explosion damage to fixed instead of random values.
- Changed how default texture pack is loaded.
    - The default texture pack is always copied to the mods folder at the start of the game.
    - The default texture pack is loaded directly from the mods folder.




# Version 0.14.0.1489 - 2018-01-26

## Additions
- Added a new user interface overlay which contains detailed information about the currently selected creature and the tile the mouse cursor is hovering over.
- Added message log which displays information about what is going on in the game. It only shows events which can be seen by the player's faction. The direction of the message log can be inverted in the options screen.
- Added creature classes (Stalker, Bandit, ...) as a basis for more detailed creatures in the future.
- Added creature groups to determine which creatures to spawn for each team. For example dogs can now spawn on the enemy team.
- Added new health system which re-introduces health points and has a simplified body model. There is a chance for status effects like blindness to occur on critical hits.
- Added new image font.
- Added sprites that are based on a creature's class rather than its body type. This allows us to bring back the "bad knight" sprite for bandits.

## Removals
- Removed health screen. It has been replaced by the new player info screen.

## Fixes
- Fixed tiles being hit twice by a projectile on some occasions.
- Fixed savegames not being sorted correctly. Savegames are now sorted by the time of their creation.

## Other Changes
- Changed item stats in inventory to include damage values for weapons.




# Version 0.13.1.1413 - 2017-12-28

## Fixes
- Fixed crash when trying to create a save game.
- Fixed crash when trying to path through a closed door with a creature that doesn't have enough action points to open the door.




# Version 0.13.0.1401 - 2017-12-24

## Additions
- Added connected sprites for walls and fences.
- Added custom item sprites and colors.
- Added versioning for the settings file. If the game detects an outdated file, it will replace it with the updated one.
- Added new section to the options screen which allows the reconfiguration of keybindings.
- Added key controls for panning the camera.
- Added option to activate mouse panning (deactivated by default).

## Removals
- Removed map exploration. Instead of hiding unexplored tiles, the map is now fully visible to the player. Tiles which can't be seen by the player's characters are still drawn in greyscale.
- Removed restrictions for the pathfinding algorithm. Characters can now find a path from one side of the map to the other (but it might take a while). Performance improvements for the pathfinding are being worked on as well.
- Removed manual flushing of LuaJIT cache. This was necessary originally since LuaJIT had troubles freeing memory with the closure based approach to oop used before. Now that all classes are using a metatable based approach the garbage collector works as expected.

## Fixes
- Fixed badly placed windows in small house prefab.
- Fixed prefab-editor being updated and drawn when menu is open.
- Fixed settings screen warning about unsaved changes even if none of the values had changed.
- Fixed faulty offset between sections in changelog screen.
- Fixed the heuristic of the pathfinding module for diagonal movement.
- Fixed volume calculation for backpacks dropped at invalid locations (e.g. outside of the inventory screen).

## Other Changes
- Changed translator warnings so they are only logged once.
- Changed spawnpoints to ignore certain tiles (e.g. shallow water).
- Changed input dialog to only delete the full text the first time backspace is pressed. Every press after that will only remove a single character.
- Changed health screen to give better indication of a character's current health and status.
- Changed controls to be saved in and loaded from the settings file instead of being hardcoded.
- Changed pathfinding algorithm to prevent pathfinding to invalid target tiles
- Changed threshold for dying from bleeding. A creature now dies when its blood volume reaches 50%.




# Version 0.12.2.1222 - 2017-11-29

## Fixes
- Fixed outdated save game versions crashing the game
- Fixed buttons not being set to inactive state correctly




# Version 0.12.1.1218 - 2017-11-29

## Fixes
- Fixed reload action taking non-ammunition items to fill magazines




# Version 0.12.0.1207 - 2017-11-24

## Additions
- Added input dialog which allows custom savegame names
- Added ingame map editor which allows to create layouts and prefabs which are used by the procedural map generator (can be activated in the options menu)
- Added new map layouts
- Added new prefabs

## Fixes
- Fixed text content of UISelectField not matching the width of the actual UIElement
- Fixed window flickering for a moment on game start
- Fixed overlapping buttons on horizontal ui lists

## Other Changes
- Settings can now be saved to disk
    - Adjusted the options menu to apply changed settings only when the user clicks on apply. It will also warn the user if there are unsaved changes upon closing the screen.
- Renamed button "Close" to "Resume" on Ingame-Menu
- Changed path for external texturepacks to "mods/texturepacks"
- The default texture pack is now copied to the mods folder on game start
- Update sprite definition for tile_grass
- Optimized search for valid spawnpoints (with the old method it could take up to a few hundred tries to spawn a character - now it takes only 3 on average)




# Version 0.11.1.1132 - 2017-11-08

## Fixes
- Fixed offset between screen mouse coordinates and game world coordinates
- Fixed blurry menu titles being caused by drawing at non-integer coordinates if screen dimensions were odd
- Fixed eplosive weapons not triggering when hitting empty tiles

## Other Changes
- Health screen can be closed by pressing 'h' again
- Make sure mouse cursor is visible in combat state




# Version 0.11.0.1125 - 2017-11-08

## Additions
- Added letterboxing to hide parts of the screen which don't fit on the tile grid
- Added Changelog screen to the main menu

## Removals
- Removed old base screen
- Removed german translation
- Removed generators and templates for static maps

## Fixes
- Fixed issue with registering attacks hitting indestructible objects
- Fixed alignment of ui items when the window is resized
- Fixed camera grid alignment
- Fixed inventory items not being dropped when a character bled to death

## Other Changes
- Calculated deviation for ranged shots is floored instead of rounded
- Updated the savegame screen
- Limited mouse cursor for the UI to the actual screen grid
- Player-controlled characters now always spawn with a ranged weapon (additionally they either get a melee or some throwing weapons)




# Version 0.10.0.1089 - 2017-10-28

## Additions
- Added ammo indicator which displays the total amount of ammunition a character has in his inventory
- Added basics for parcel based procedural map generation
    - Map layouts determine the general look of the map such as road placement and where parcels are placed
    - Building-prefabs can be spawned in parcels matching their size
    - Prefabs can be rotated randomly
    - Spawn randomly generated foliage parcels
- Added completely revamped inventory user interface
    - General groundwork for future user interface additions

## Removals
- Removed unused resource file
- Removed heal all selector on base screen

## Fixes
- Fixed crash on base screen when health screen was opened before a character was selected

## Other Changes
- Character names are aligned to the left now
- Improved interaction between mouse and keyboard controls in menu screens
- Nationalities are now picked from a weighted list to control the rarity of certain nations
- The aim overlay will always mark unseen tiles as potentially blocking
- Changed minimum resolution from 800x600 to 1024x768
- Improved the ingame help screen and updated it to follow the general UI style




# Version 0.9.2.1079 - 2017-10-28

## Fixes
- Fix crash caused by faulty parser pattern




# Version 0.9.1.1073 - 2017-10-28

## Fixes
- Fix infinite loading bug on macOS High Sierra 10.13




# Version 0.9.0.1014 - 2017-04-18

## Additions
- Added basic base gameplay
    - Base inventory can be used to store items between missions
        - The inventory screen can be opened for an active character by pressing "i"
    - A new combat mission can be started by pressing the "next mission" button
    - All characters can be healed by pressing "Heal All"
        - The health screen can be opened for an active character by pressing "h"
- Added proper saving system
    - Added a menu for loading savegames
    - Savegames are stored and ordered by their time of creation
    - Savegames which have been created with older versions of the game are marked as incompatible
- Added footer to all menu screens
- Added randomly generated nationality and names for characters

## Removals
- Removed unused translation strings

## Other Changes
- Colors and sprites can now be entirely defined via texture packs
- Replaced randomized ASCII sprites for shotgun shots with different sprite
- Exposed "Type:" string to translation files
- Changed health screen hotkey from "q" to "h"




# Version 0.8.2.976 - 2017-04-14

## Fixes
- Fixed crash when trying to drag an item stack in the inventory screen
- Fixed highlighting of equipment slots not being removed correctly




# Version 0.8.1.949 - 2017-04-09

## Fixes
- Fixed bug where a character's inventory volume wasn't reset correctly




# Version 0.8.0.933 - 2017-04-02

## Additions
- Added height mechanics for world objects and characters
    - World objects that are bigger than a character will block the LOS
    - Shooting over a world object is only possible if the target behind the object can be seen
- Added texture pack support
    - Users can add their own texture packs in the mod/texturepacks folder located in their save directory
    - Texture packs support arbitrary tile sizes
- Added support for loading multiple maps
    - Added a second map
- Added "Show Help" button to ingame menu

## Removals
- Removed hotkey for help screen (and the ingame overlay for it)
- Removed "Close" button from ingame menu
    - It can be closed via the escape-key now

## Fixes
- Fixed button receiving events without actually having focus
- Fixed status effects being applied more than once

## Other Changes
- Attack and interaction modes are now toggleable
    - Pressing their keys again will switch back to the movement mode




# Version 0.7.1.883 - 2017-03-20

## Fixes
- Fixed health screen not opening for adjacent chars
- Fixed missing text for dog legs




# Version 0.7.0.880 - 2017-03-19

## Additions
- Added main menu
    - Can be navigated via mouse or keyboard
- Added options menu
    - Allows the user to change the language (currently only german and english available)
    - Allows to toggle fullscreen mode
- Added ingame menu
    - Allows user to save the game or to exit back to main menu
- Added german translation
- Added savegames

## Removals
- Removed spawning of ammo in crates at the start of the game

## Fixes
- Fixed memory leak caused by upvalues and closures not being collected with LuaJIT enabled
- Fixed crash with pathfinding in cases where the target was the same as the origin
- Fixed removal of previous movement paths when character was selected via mouse click




# Version 0.6.0.841 - 2017-03-09

## Additions
- Added random spawning of items when a world object is destroyed
- Added interaction with inventory of adjacent tiles
- Added automatic opening of container objects if they are the target of a movement path
- Added dogs as the first non-human creatures
- Added a passive AI for the neutral faction
    - The neutral faction now only consists of dogs
    - The neutral faction is ignored by the other factions
- Added AI actions for picking up items
- Added inspection of other characters (clicking on them in interact mode opens their health panel)
- Added damage reduction based on worn armor items
- Added simple gameover screen

## Removals
- Removed automatic camera movement during attacks

## Fixes
- Fixed color code for impassable world objects when aiming
- Fixed potential error where projectiles weren't updated if one of them hit the map borders
- Fixed error where tiles were hit twice if the projectile lost all energy

## Other Changes
- Use an improved algorithm for FOV calculations
- Improve bleeding mechanics
    - Apply bleeding effects directly on a hit instead of waiting till the next round
    - Amount of blood loss is now based on the damage type of the attack
    - Weak body parts will receive higher bleeding damage
- Updated the inventory system
    - Container items such as backpacks now increase a character's carry capacity
    - When the item is unequipped all items that don't fit the inventory will be dropped
- Increased inventory size for tiles
- Updated colors for neutral characters
- Improved the health screen
    - Added better bleeding indicators
    - The character type is now also displayed
- General balancing trying to slowly move towards a good "feel" for the combat
- Changed world objects to not block shots when the character is adjacent to them
    - This only applies to world objects that are small enough
- Changed size of door objects
- Improved balancing for damage values of explosive weapons




# Version 0.5.2.741 - 2017-02-11

## Fixes
- Fixed issue where the AI would start the execution state twice
- Fixed actions being executed for dead characters
- Fixed AI handler failing to end its turn




# Version 0.5.1.727 - 2017-02-10

## Other Changes
- Reduced debug output




# Version 0.5.0.725 - 2017-02-09

## Additions
- Added a new smaller map with more tactical possibilities
    - Added new tiles "Gravel" and "Wooden Floor"
    - Added new world object "Tree"
- Added preliminary item descriptions
- Added log file writer
- Added indicator displaying the AP costs for an action

## Removals
- Removed german translation files for now
- Removed automatic changing to crouched mode when a character climbs over a world object

## Fixes
- Fixed AP cost calculation in pathfinding algorithm
- Fixed enqueuing of impossible actions
- Fixed AI getting stuck in behavior tree
- Fixed crash with the Rearm Action

## Other Changes
- Changed colors of crate objects
- General improvements of the user interface
    - Debug info is hidden by default
    - Rearranged the other UI components to match the game's grid system
- Changed movement input to use two stages again
    - The first click plots the path
    - The second click starts the actual movement
- AP cost for interacting with a world object is now dependent on the character's stance
- AP cost for traversing a tile is now dependent on the character's stance
- Help and debug info overlays are still visible during AI turns
- Camera now starts centered on the map




# Version 0.4.3.685 - 2017-02-06

## Fixes
- Revert "Fix impossible actions being added to the queue" as it caused additional problems




# Version 0.4.2.668 - 2017-02-05

## Fixes
- Keep health screen centered when screen is resized
- Prevent crash when screen is resized while inventory is open
- Fix enqueuing of action which can't be performed




# Version 0.4.1.664 - 2017-02-04

## Other Changes
- Deactivated save feature
- Made chairs and tables climbable




# Version 0.4.0.658 - 2017-02-04

## Additions
- Added knife item to test slashing damage
- Added the first implementation of an in-depth health system
    - Each create has an actual body model consisting of separate body parts
    - Each body part does have its own effects and attributes
        - Destroying a vital organ leads to a character's death
        - Destroying the eyes will blind the character
    - Attacks can cause bleeding which can lead to a character's death
- Added a custom image font for the user interface
- Added simple health screen

## Fixes
- Fix merging of item stacks
- Fix camera moving while inventory is open
- Fix issue with Lua's default io libs

## Other Changes
- Do not restore camera position after movement
- Reduced amount of camera movement during AI turns
- Taught AI to rearm throwing weapons
- Use layout-independent key scancodes
- Added a custom error handler
- Made throwable weapons stackable
- Equipment slots are no longer hardcoded but can be determined by a character's body template
- Hide equipment when looking at another character's inventory
- The camera actually takes tile sizes into account when moving
- Mouse Pointer is no longer updated when the inventory is open
- Made game window resizable (minimum size is locked to 800x600)
- General inventory layout improvements
    - Added scrollable item description area
    - Added item stats area




# Version 0.3.1.573 - 2016-12-01

## Additions
- Added damage types for weapons: currently doesn't have effects on gameplay yet
- Added keybinding for deleting the save file

## Fixes
- Prevent interaction with world objects if character isn't adjacent to them

## Other Changes
- Improved help screen
- Characters rearm with throwing weapons after using them




# Version 0.3.0.564 - 2016-11-10

## Additions
- Added keybinding which toggles fullscreen
- Added keybinding for quitting the game
- Added a translation system
- Added crate world objects which act as item containers
    - Ammo is spawned randomly in these crates when the game starts
    - Characters can open and interact with the container's inventory by using the "interact" mode
- Added inventory screen for swapping items between friendly characters
- Added weight attributes for items
- Added volume attributes for items
- Added weight and volume limitation for inventory containers (bags, tiles, etc.)
    - Inventory lists show the current weight and the weight limit
- Added stackable items
    - Items in stacks can be moved one-by-one or as as the whole stack
    - Stacks can be split in half
    - Stacks can be merged
- Added functionality to allow arbitrary item sorting in the inventory
- Added a maximum range for weapons
- Added line-of-sight overlay for grenades
- Added a cone overlay representing the maximum angle at which a projectile can divert from its intended target
- Added a small version info overlay
- Added a quick-help screen

## Removals
- Removed a bunch items until the item and inventory system is a bit more stable

## Fixes
- Fixed serialization and loading of openable world objects
- Fixed unequippable items vanishing when trying to equip them
- Fixed crash when trying to switch firing modes without a weapon equipped
- Fixed grenades being removed upon explosion instead of being thrown
- Fixed crash when a character tries to attack its own tile
- Fixed crash with dropping a character's inventory on death

## Other Changes
- The game starts in fullscreen now by default
- The mouse scrolling stops if the mouse cursor leaves the game's window
- Increased the size of the mouse scrolling area
- Renamed Police Baton to Tonfa
- Ammunition is now handled on a single-round level instead of using magazines
- Pathfinding now uses the more appropriate Chebyshev distance as an heuristic
- Updated spawnpoints for player's characters




# Version 0.2.2.455 - 2016-09-13
## Fixes
- Fixed drawing of overlays for actions that can't be executed
- Fixed crash when shooting an adjacent world object
- Fixed crash when a grenade hit a world object




# Version 0.2.1.450 - 2016-09-12
## Fixes
- Fixed crash when trying to load a savegame containing grenades
- Fixed issue with rockets failing to explode when hitting an indestructible object
- Fixed crash when trying to reload with no (ranged) weapon equipped




# Version 0.2.0.445 - 2016-09-11
## Additions
- Added system to handle calculation, updating and drawing of explosions
- Added a specific mouse cursor graphic for each of the input states
- Added system to create spawn areas for the different factions
- Added simple savegame functionality
- Added shotguns
- Added rocket launchers
- Added melee weapons
- Added grenades
- Added a behavior tree system for the AI controlled factions

## Fixes
- Fixed crash when walking through open doors
- Fixed backpacks being placed inside of themselves
- Fixed crash on inventory screen with no backpack equipped
- Fixed interaction with unequipped backpacks
- Fixed interaction with dead characters
- Fixed camera not being centered on selected character when game starts
- Fixed AP cost for attempting attack with empty weapon
- Fixed hidden mouse cursor in inventory screen
- Fixed projectiles not being removed correctly
- Fixed rockets not exploding on impact
- Fixed flickering mouse cursor during AI turns

## Other Changes
- Improved camera handling during execution of a turn
    - It will follow moving characters now
    - It will track the target of an attack
    - It is locked during the execution of the turn
    - It will return to its original position after the turn is done
    - It is restricted to the map's area
    - Disable camera tracking for AI controlled characters
- FOV isn't drawn for AI controlled factions
- Tweaked shot calculations
    - Uses the maximum angle for a shot's deviation correctly now
    - Randomly varies the projectile's traveling distance
- Improved line of sight drawing
    - Line of sight is now generated in real time between the active character and the mouse cursor
- Center the camera on characters which have been selected via right-clicks
- Use different sounds based on the selected weapon type
- Reduce turn delay for AI controlled characters
- Updated the map




# Version 0.1.0.337 - 2016-07-31

## Additions
- Initial Release
- Add basic implementation of turn based combat mechanics
    - Three different factions
    - Simple AI
    - Movement, Attacking and Interaction modes
- Tilebased world map loaded from template file
    - Tile layer determines the ground
    - Object layer determines WorldObjects like walls and doors
- Simple inventory system
    - Items can be equipped or removed
    - Reloading takes magazines from a characters backpack

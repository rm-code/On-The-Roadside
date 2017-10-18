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
- Renamed _Police Baton_ to _Tonfa_
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
    - Uses the maximum angle for a shot's derivation correctly now
    - Randomly varies the projectile's traveling distance
- Improved line of sight drawing
    - Line of sight is now generated in real time between the active character and the mouse cursor
- Center the camera on characters which have been selected via right-clicks
- Use different sounds based on the selected weapon type
- Reduce turn delay for AI controlled characters
- Updated the map




# Version 0.1.0.337 - 2016-07-31
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

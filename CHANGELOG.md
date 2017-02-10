# Version 0.5.1.727 - 2017-02-10

## Other Changes
- Reduced debug output




# Version 0.5.0.725 - 2017-02-09

## Additions
- Added a new smaller map with more tactical possibilites
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
- Fixed enqueuing of impossible actions ([#104](https://github.com/rm-code/On-The-Roadside/issues/104))
- Fixed AI getting stuck in behavior tree ([#106](https://github.com/rm-code/On-The-Roadside/issues/106))
- Fixed crash with the Rearm Action ([#107](https://github.com/rm-code/On-The-Roadside/issues/107))

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
- Keep health screen centered when screen is resized ([#103](https://github.com/rm-code/On-The-Roadside/issues/103))
- Prevent crash when screen is resized while inventory is open ([#98](https://github.com/rm-code/On-The-Roadside/issues/98))
- Fix enqueuing of action which can't be performed ([#93](https://github.com/rm-code/On-The-Roadside/issues/93))




# Version 0.4.1.664 - 2017-02-04

## Other Changes
- Deactivated save feature
- Made chairs and tables climbable ([#94](https://github.com/rm-code/On-The-Roadside/issues/94))




# Version 0.4.0.658 - 2017-02-04

## Additions
- Added knife item to test slashing damage
- Added the first implementation of an in-depth health system
    - Each create has an actual body model consisting of separate body parts
    - Each body part does have its own effects and attributes
        - Destroying a vital organ leads to a character's death
        - Destroying the eyes will blind the character
    - Attacks can cause bleeding which can lead to a character's death
- Added a custom image font for the user interface ([#86](https://github.com/rm-code/On-The-Roadside/issues/86))
- Added simple (preliminary) health screen

## Fixes
- Fix merging of item stacks ([#84](https://github.com/rm-code/On-The-Roadside/issues/84))
- Fix camera moving while inventory is open ([#90](https://github.com/rm-code/On-The-Roadside/issues/90))
- Fix issue with Lua's default io libs ([#91](https://github.com/rm-code/On-The-Roadside/issues/91))

## Other Changes
- Do not restore camera position after movement ([#43](https://github.com/rm-code/On-The-Roadside/issues/43))
- Reduced amount of camera movement during AI turns
- Taught AI to rearm throwing weapons
- Use layout-independent key scancodes ([#82](https://github.com/rm-code/On-The-Roadside/issues/82))
- Added a custom error handler
- Made throwable weapons stackable ([#83](https://github.com/rm-code/On-The-Roadside/issues/83))
- Equipment slots are no longer hardcoded but can be determined by a character's body template
- Hide equipment when looking at another character's inventory
- The camera actually takes tile sizes into account when moving
- Mouse Pointer is no longer updated when the inventory is open ([#87](https://github.com/rm-code/On-The-Roadside/issues/87))
- Made game window resizable (minimum size is locked to 800x600)
- General inventory layout improvements
    - Added scrollable item description area
    - Added item stats area




# Version 0.3.1.573 - 2016-12-01

## Additions
- Added damage types for weapons: currently doesn't have effects on gameplay yet ([#74](https://github.com/rm-code/On-The-Roadside/issues/74))
- Added keybinding for deleting the save file

## Fixes
- Prevent interaction with world objects if character isn't adjacent to them ([#75](https://github.com/rm-code/On-The-Roadside/issues/75))

## Other Changes
- Improved help screen ([#80](https://github.com/rm-code/On-The-Roadside/issues/80))
- Characters rearm with throwing weapons after using them ([#77](https://github.com/rm-code/On-The-Roadside/issues/77))




# Version 0.3.0.564 - 2016-11-10

## Additions
- Added keybinding which toggles fullscreen ([#37](https://github.com/rm-code/On-The-Roadside/issues/37))
- Added keybinding for quitting the game
- Added a translation system ([#51](https://github.com/rm-code/On-The-Roadside/issues/51))
- Added crate world objects which act as item containers ([#42](https://github.com/rm-code/On-The-Roadside/issues/42))
    - Ammo is spawned randomly in these crates when the game starts
    - Characters can open and interact with the container's inventory by using the "interact" mode
- Added inventory screen for swapping items between friendly characters ([#59](https://github.com/rm-code/On-The-Roadside/issues/59))
- Added weight attributes for items ([#44](https://github.com/rm-code/On-The-Roadside/issues/44))
- Added volume attributes for items ([#65](https://github.com/rm-code/On-The-Roadside/issues/65))
- Added weight and volume limitation for inventory containers (bags, tiles, etc.) ([#48](https://github.com/rm-code/On-The-Roadside/issues/48))
    - Inventory lists show the current weight and the weight limit ([#62](https://github.com/rm-code/On-The-Roadside/issues/62))
- Added stackable items ([#45](https://github.com/rm-code/On-The-Roadside/issues/45))
    - Items in stacks can be moved one-by-one or as as the whole stack ([#57](https://github.com/rm-code/On-The-Roadside/issues/57))
    - Stacks can be split in half ([#58](https://github.com/rm-code/On-The-Roadside/issues/58))
    - Stacks can be merged ([#61](https://github.com/rm-code/On-The-Roadside/issues/61))
- Added functionality to allow arbitrary item sorting in the inventory ([#60](https://github.com/rm-code/On-The-Roadside/issues/60))
- Added a maximum range for weapons ([#63](https://github.com/rm-code/On-The-Roadside/issues/63))
- Added line-of-sight overlay for grenades ([#64](https://github.com/rm-code/On-The-Roadside/issues/64))
- Added a cone overlay representing the maximum angle at which a projectile can divert from its intended target ([#71](https://github.com/rm-code/On-The-Roadside/issues/71))
- Added a small version info overlay
- Added a quick-help screen

## Removals
- Removed a bunch items until the item and inventory system is a bit more stable

## Fixes
- Fixed serialization and loading of openable world objects ([#49](https://github.com/rm-code/On-The-Roadside/issues/49))
- Fixed unequippable items vanishing when trying to equip them ([#54](https://github.com/rm-code/On-The-Roadside/issues/54))
- Fixed crash when trying to switch firing modes without a weapon equipped
([#55](https://github.com/rm-code/On-The-Roadside/issues/55))
- Fixed grenades being removed upon explosion instead of being thrown
- Fixed crash when a character tries to attack its own tile
([#68](https://github.com/rm-code/On-The-Roadside/issues/68))
- Fixed crash with dropping a character's inventory on death
([#70](https://github.com/rm-code/On-The-Roadside/issues/70))

## Other Changes
- The game starts in fullscreen now by default
- The mouse scrolling stops if the mouse cursor leaves the game's window ([#38](https://github.com/rm-code/On-The-Roadside/issues/38))
- Increased the size of the mouse scrolling area
- Renamed _Police Baton_ to _Tonfa_
- Ammunition is now handled on a single-round level instead of using magazines ([#52](https://github.com/rm-code/On-The-Roadside/issues/52))
- Pathfinding now uses the more appropriate Chebyshev distance as an heuristic ([#66](https://github.com/rm-code/On-The-Roadside/issues/66))
- Updated spawnpoints for player's characters




# Version 0.2.2.455 - 2016-09-13
## Fixes
- Fixed drawing of overlays for actions that can't be executed ([#35](https://github.com/rm-code/On-The-Roadside/issues/35))
- Fixed crash when shooting an adjacent world object ([#39](https://github.com/rm-code/On-The-Roadside/issues/39))
- Fixed crash when a grenade hit a world object ([#40](https://github.com/rm-code/On-The-Roadside/issues/40))




# Version 0.2.1.450 - 2016-09-12
## Fixes
- Fixed crash when trying to load a savegame containing grenades ([#32](https://github.com/rm-code/On-The-Roadside/issues/32))
- Fixed issue with rockets failing to explode when hitting an indestructible object ([#33](https://github.com/rm-code/On-The-Roadside/issues/33))
- Fixed crash when trying to reload with no (ranged) weapon equipped ([#34](https://github.com/rm-code/On-The-Roadside/issues/34))




# Version 0.2.0.445 - 2016-09-11
## Additions
- Added system to handle calculation, updating and drawing of explosions ([#6](https://github.com/rm-code/On-The-Roadside/issues/6))
- Added a specific mouse cursor graphic for each of the input states ([#11](https://github.com/rm-code/On-The-Roadside/issues/11))
- Added system to create spawn areas for the different factions ([#13](https://github.com/rm-code/On-The-Roadside/issues/13))
- Added simple savegame functionality ([#16](https://github.com/rm-code/On-The-Roadside/issues/16))
- Added shotguns ([#19](https://github.com/rm-code/On-The-Roadside/issues/19))
- Added rocket launchers ([#20](https://github.com/rm-code/On-The-Roadside/issues/20))
- Added melee weapons ([#25](https://github.com/rm-code/On-The-Roadside/issues/25))
- Added grenades ([#10](https://github.com/rm-code/On-The-Roadside/issues/10))
- Added a behavior tree system for the AI controlled factions ([#29](https://github.com/rm-code/On-The-Roadside/issues/29))

## Fixes
- Fixed crash when walking through open doors ([#4](https://github.com/rm-code/On-The-Roadside/issues/4))
- Fixed backpacks being placed inside of themselves ([#7](https://github.com/rm-code/On-The-Roadside/issues/7))
- Fixed crash on inventory screen with no backpack equipped ([#8](https://github.com/rm-code/On-The-Roadside/issues/8))
- Fixed interaction with unequipped backpacks ([#9](https://github.com/rm-code/On-The-Roadside/issues/9))
- Fixed interaction with dead characters ([#17](https://github.com/rm-code/On-The-Roadside/issues/17))
- Fixed camera not being centered on selected character when game starts ([#18](https://github.com/rm-code/On-The-Roadside/issues/18))
- Fixed AP cost for attempting attack with empty weapon ([#21](https://github.com/rm-code/On-The-Roadside/issues/21))
- Fixed hidden mouse cursor in inventory screen ([#22](https://github.com/rm-code/On-The-Roadside/issues/22))
- Fixed projectiles not being removed correctly ([#28](https://github.com/rm-code/On-The-Roadside/issues/28))
- Fixed rockets not exploding on impact ([#30](https://github.com/rm-code/On-The-Roadside/issues/30))
- Fixed flickering mouse cursor during AI turns ([#31](https://github.com/rm-code/On-The-Roadside/issues/31))

## Other Changes
- Improved camera handling during execution of a turn ([#27](https://github.com/rm-code/On-The-Roadside/issues/27))
    - It will follow moving characters now
    - It will track the target of an attack
    - It is locked during the execution of the turn
    - It will return to its original position after the turn is done
    - It is restricted to the map's area
    - Disable camera tracking for AI controlled characters ([#26](https://github.com/rm-code/On-The-Roadside/issues/26))
- FOV isn't drawn for AI controlled factions ([#26](https://github.com/rm-code/On-The-Roadside/issues/26))
- Tweaked shot calculations ([#24](https://github.com/rm-code/On-The-Roadside/issues/24))
    - Uses the maximum angle for a shot's derivation correctly now
    - Randomly varies the projectile's travelling distance
- Improved line of sight drawning
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

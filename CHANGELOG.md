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

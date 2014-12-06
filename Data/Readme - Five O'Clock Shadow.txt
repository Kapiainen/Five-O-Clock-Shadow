Five O'Clock Shadow
Version: 3.0.3
Author: MrJack

Table of contents
- Description
- Requirements
- Compatibility
- How to install
- How to use
- How to uninstall
- Credits
- How to contact the author
- Changelog


--Description--
Do you spend days, weeks, or months on end adventuring? Do you wish that all of that time far from civilization affected the look of your character and his/her followers? Five O'Clock Shadow is a mod that makes your character's and his/her followers' facial hair grow as time passes.

You can use a razor (FormID xx00D28E) to:
- maintain the player character's facial hair at its current state
- let the player character's facial hair grow again
- trim the length by one step
- trim to the longest possible version of the chosen style of facial hair based on the current length of facial hair
- shave all facial hair off
- select the style of facial hair: beard, chinstrap, goatee, goat patch, horseshoe, moustache, muttonchops, sideburns, or Van Dyke
- change settings: time required for facial hair to grow by one step, switch between growth occurring at any time or only when sleeping, enable/disable cutscenes, enable/disable follower support, enable/disable Brawl Bug fix

Follower support is disabled by default and must be enabled via the settings menu (read the previous paragraphs for more information), if one wants to use it. A follower's facial hair grows at the same rate as the player's, but growth can occur at any time as long as the player isn't looking at the follower. The facial hair, which the follower has when he becomes a follower, is assumed to be his preferred style. A follower will shave and reacquire their default facial hair, when the player sleeps in an inn or player home, provided that the follower is in the same place. Followers must meet the following conditions to be supported by the system: be male, not be a beast race (Argonian, Khajiit, etc.), have one of the support styles of facial hair, and be in the PlayerFollowerFaction and CurrentFollowerFaction factions. Followers who leave your party have their default facial hair restored about an hour (in-game) after they've left, provided that the ex-follower and the player are in different cells, and the player does not have line of sight to the ex-follower. This restoration is attempted repeatedly until successful. If a follower dies, then their facial hair is not reset until the next time the game is started. If a follower's facial hair cannot be identified (probable causes include facial hair from an unsupported mod), then the NPC will be flagged as incompatible by adding an ability to him.

If you use the plugin that doesn't include conditions to stop the follower cloak during brawls, then you should use jonwd7's Brawl Bugs Patch. If you use the plugin that does include conditions to temporarily disable the cloak during brawls, then you might end up in a situation where new followers aren't supported until the brawl has occurred. You can force a follower into one of the slots by giving them a specific spell (FormID xx00C7C8) via the console, if a potential upcoming brawl has been detected and followers aren't being added to slots.


--Requirements--
Skyrim (>= 1.9.32.0.8)
SKSE (>= 1.7.1)


--Compatibility--
There shouldn't be any compatibility issues, unless you are using another mod that changes the facial hair used by the player character while playing.


--How to install--
1. Extract contents to "\Skyrim\Data" (manual) or install archive with your favorite mod manager (Nexus Mod Manager, Mod Organizer, etc.)
2. Activate "Five O'Clock Shadow.esp"


--How to use--
The mod will attempt the identify the facial hair of the player character and determine the correct style when the mod is loaded. If you have not finished the creating your character, then the message will be repeated once you leave the character creation menu, provided that you answered accordingly to the popup message.

Trimming the length of facial hair works in one of two ways:
- facial hair growth is reversed by one step, if the facial hair isn't trimmed to a particular style
- the length of a style is trimmed shorter, if the facial hair is trimmed to a particular style

Trimming to a certain style trims the facial hair into the longest possible length of the chosen style that the current length of facial hair can support.

Clean shave is what it sounds like; everything is shaved off.


--How to uninstall--
Uninstalling in the middle of a playthrough is not supported as some data may have been baked into the save.

- Remove "Five O'Clock Shadow.esp" and "Five O'Clock Shadow.bsa" from "\Skyrim\Data".


--Credits--
The SKSE team.
This mod uses these sounds from freesound.org:
 - Shaving.aif by charliemidi


--How to contact the author--
PM MrJack on the official Bethesda forums or mrpwn on Nexus.


--Changelog--
3.0.3:
- Added ability to toggle the Brawl Bug fix at runtime in the razor's settings menu. An optional plugin, like the ones used by previous versions, is no longer necessary. This new option is only visible when follower support is enabled.

3.0.2:
- Added stubble to some stages of facial hair that were missing it.
- Added one more length to the full beard style.
- Fixed a bug with trimming to a style.

3.0.1:
- Disabled certain buttons in the razor menu when playing as a beast race.
- Fixed a bug where beast races might grow facial hair despite not being among the supported races.

3.0.0:
- Overhaul of the mod.
- Added follower support. Ten slots for followers, but more can be added if necessary.

2.0.0:
- Overhaul of the mod's internals. 
- Added a mod configuration menu with the following options: 
- Set duration of stages (1-168 hours). 
- Limit update of facial hair to whenever the player wakes up. 
- Switch between the default lesser power and a razor for configuration purposes. 
- Added a lot more stages by modifying the beard meshes (all non-Khajiit styles share the first two stages). The current number of unique stages are (+modifications): 
- Beard: 67 (+2) 
- Chinstrap: 3 (+0) 
- Goatee: 19 (+1, +7 if the "Beards" mod is active) 
- Goat patch: 9 (+1) 
- Horseshoe: 12 (+0) 
- Moustache: 10 (+0) 
- Muttonchops: 24 (+0) 
- Sideburns: 24 (+0) 
- Sideburns (Khajiit): 17 (+2) 
- Some progress can be retained when switching from a style with more facial hair to one with less facial hair.

1.0.0:
- Initial release
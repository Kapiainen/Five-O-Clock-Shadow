Five O'Clock Shadow
Version: 1.0.0
Author: MrJack

Table of contents
- Description
- Requirements
- Compatibility
- How to install
- How to uninstall
- How to contact the author


--Description--
This mod will make growing a beard take time and happen in stages. You can trim your facial hair, maintain it at its current state, let it grow or perform a clean shave. There are currently 8 different styles of facial hair to select from with the full beard being the most detailed in terms of number of stages.

If you intend to only use a specific style of facial hair on a player character, then this mod should be disabled for that player character.
The feature is disabled if the player character is an Argonian or a Khajiit.

Technical details: The mod works by periodically changing HeadParts, which are stored in FormLists that are specific to each style of facial hair. The facial hair can be adjusted by using a power called "Facial Hair" (FormID XX000D6D, XX is the mod's index in the load order).


--Requirements--
Skyrim (>= 1.9.32.0.8)
SKSE (>= 1.6.16)


--Compatibility--
There shouldn't be any compatibility issues, unless you are using another mod that changes the facial hair used by the player character while playing.


--How to install--
1. Extract contents to "\Skyrim\Data" (manual) or install archive (Nexus Mod Manager, Mod Organizer, etc.)
2. Activate "Five O'Clock Shadow.esp"

A lesser power called "Facial Hair" should be added to the player character as long as he is not an Argonian or a Khajiit. If the lesser power hasn't been added, then do so via the console:

player.addspell XX000D6D

Replace XX with this mod's index in the load order. You can find the index in game by typing the following in the console:

help "facial hair"

A spell called "Facial Hair" should be listed among any other entries that contain the text that was searched for.


--How to uninstall--
Uninstalling in the middle of a playthrough is not supported as some data may have been baked into the save.

- Remove "Five O'Clock Shadow.esp" and "Five O'Clock Shadow.bsa" from "\Skyrim\Data".


--How to contact the author--
PM MrJack on the official Bethesda forums or mrpwn on Nexus.
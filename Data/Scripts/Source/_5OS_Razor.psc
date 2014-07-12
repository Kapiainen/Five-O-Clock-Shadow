Scriptname _5OS_Razor extends ObjectReference  

_5OS_BeardGrowth Property System Auto

Event OnEquipped(Actor akActor)
	Game.DisablePlayerControls()
	Utility.Wait(0.1)
	Game.EnablePlayerControls()
	System.ConfigMenu()
EndEvent

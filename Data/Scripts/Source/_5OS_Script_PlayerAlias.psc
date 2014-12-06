Scriptname _5OS_Script_PlayerAlias extends ReferenceAlias  

Event OnPlayerLoadGame()
	Quest kQuest = GetOwningQuest()
	(kQuest as _5OS_Script_BeardGrowth).OnPlayerLoadGame()
	Int iCount = kQuest.GetNumAliases()
	Int i = 0
	While(i < iCount)
		ReferenceAlias kRefAlias = kQuest.GetNthAlias(i) as ReferenceAlias
		If(kRefAlias)
			If(kRefAlias != Self) && (kRefAlias.GetActorReference())
				(kRefAlias as _5OS_Script_FollowerAlias).OnPlayerLoadGame()
			EndIf
		EndIf
		i += 1
	EndWhile
EndEvent

Event OnRaceSwitchComplete()
	(GetOwningQuest() as _5OS_Script_BeardGrowth).OnRaceSwitchComplete()
EndEvent

Function SettingChange()
	Quest kQuest = GetOwningQuest()
	Int iCount = kQuest.GetNumAliases()
	Int i = 0
	While(i < iCount)
		ReferenceAlias kRefAlias = kQuest.GetNthAlias(i) as ReferenceAlias
		If(kRefAlias)
			If(kRefAlias != Self) && (kRefAlias.GetActorReference())
				(kRefAlias as _5OS_Script_FollowerAlias).SettingChange()
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction
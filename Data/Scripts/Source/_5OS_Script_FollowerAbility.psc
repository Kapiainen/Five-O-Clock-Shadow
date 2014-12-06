Scriptname _5OS_Script_FollowerAbility extends activemagiceffect  

Quest Property kQuest Auto
Spell Property kAbility Auto
Faction Property PlayerFollowerFaction Auto
Faction Property CurrentFollowerFaction Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(akTarget)
		ReferenceAlias kRefAlias = GetEmptyRefAlias(kQuest, akTarget)
		If(kRefAlias)
			If(kRefAlias.GetActorReference() == akTarget)
				;Debug.Notification("Already in an alias")
				Return
			Else
				kRefAlias.ForceRefTo(akTarget)
				(kRefAlias as _5OS_Script_FollowerAlias).Start()
				Return
			EndIf
		EndIf
	EndIf
	;Couldn't find an empty alias at this point
	;Debug.Notification("No empty aliases at the moment")
	RegisterForSingleUpdateGameTime(1.0)
EndEvent

Event OnUpdateGameTime()
	Actor kTarget = Self.GetTargetActor()
	;Debug.Notification("Attempting to find an empty alias")
	OnEffectStart(kTarget, None)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster) ;Stopped being a follower
	ReferenceAlias kRefAlias = GetFilledRefAlias(kQuest, akTarget)
	If(kRefAlias)
		If((!akTarget.IsInFaction(PlayerFollowerFaction)) && (!akTarget.IsInFaction(CurrentFollowerFaction)))
			(kRefAlias as _5OS_Script_FollowerAlias).Stop() ;Final shave to restore looks
			akTarget.RemoveSpell(kAbility)
		EndIf
	EndIf
EndEvent

Event OnDying(Actor akKiller)
	;Debug.Notification("Follower died")
	Actor kTarget = Self.GetTargetActor()
	If(kTarget)
		ReferenceAlias kRefAlias = GetFilledRefAlias(kQuest, kTarget)
		If(kRefAlias)
			(kRefAlias as _5OS_Script_FollowerAlias).Die() ;Stops growth
			;kRefAlias.Clear()
			kTarget.RemoveSpell(kAbility)
		EndIf
	EndIf
EndEvent

ReferenceAlias Function GetEmptyRefAlias(Quest akQuest, Actor akActor)
	Int iCount = akQuest.GetNumAliases()
	Int i = 0
	Int iEmpty = -1
	ReferenceAlias kReferenceAlias
	While(i < iCount)
		kReferenceAlias = akQuest.GetNthAlias(i) as ReferenceAlias
		If(kReferenceAlias)
			Actor kAliasActor = kReferenceAlias.GetActorReference()
			If(!kAliasActor)
				If(iEmpty < 0)
					iEmpty = i
					;Debug.Notification("Found an empty alias")
				EndIf
			ElseIf(kAliasActor == akActor)
				;Debug.Notification("Already in an alias")
				Return kReferenceAlias
			EndIf
		EndIf
		i += 1
	EndWhile
	If(iEmpty >= 0)
		Return akQuest.GetNthAlias(iEmpty) as ReferenceAlias
	Else
		Return None
	EndIf
EndFunction

ReferenceAlias Function GetFilledRefAlias(Quest akQuest, Actor akActor)
	Int iCount = kQuest.GetNumAliases()
	Int i = 0
	ReferenceAlias kReferenceAlias
	While(i < iCount)
		kReferenceAlias = akQuest.GetNthAlias(i) as ReferenceAlias
		If(kReferenceAlias)
			If(kReferenceAlias.GetActorReference() == akActor)
				Return kReferenceAlias
			EndIf
		EndIf
		i += 1
	EndWhile
	Return None
EndFunction
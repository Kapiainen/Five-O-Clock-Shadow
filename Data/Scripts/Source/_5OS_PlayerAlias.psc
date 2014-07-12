Scriptname _5OS_PlayerAlias extends ReferenceAlias  

Actor Property PlayerRef Auto
Spell Property kPower Auto
FormList[] Property flStyles Auto
FormList Property flInvalidRaces Auto
;0 = Beard
;1 = Goatee
;2 = Horseshoe
;3 = Moustache
;4 = Muttonchops
;5 = Sideburns
;6 = Chinstrap
;7 = Goat Patch

FormList flStyle
Race PlayerRace
Int iStyle = 0
Int iStage = 0
Float fUpdateFrequency = 2.0
Float fLastUpdate = 0.0
Float fTimeSinceLastUpdate = 0.0
Float fNextUpdate = 0.0
HeadPart hpOld = None

Event OnInit()
	RegisterForMenu("RaceSex Menu")
	PlayerRace = PlayerRef.GetRace()
	AddPower()
	SetStyle(0)
EndEvent

Event OnMenuOpen(String asMenuName)
	;Debug.Notification("Opened race menu")
	hpOld = PlayerRef.GetActorBase().GetNthHeadPart(6)
	Freeze()
EndEvent

Event OnMenuClose(String asMenuName)
	;Debug.Notification("Closed race menu")
	PlayerRace = PlayerRef.GetRace()
	If(flInvalidRaces.Find(PlayerRace) < 0)
		If(PlayerRef.GetActorBase().GetSex() == 0)
			;Debug.Notification("Male")
			HeadPart hpNew = PlayerRef.GetActorBase().GetNthHeadPart(6)
			If(hpNew == hpOld)
				;Debug.Notification("Old facial hair")
				Thaw()
			Else
				SetStyle(0)
			EndIf
		Else ;Female
			;Debug.Notification("Female")
		EndIf
	Else
		
	EndIf
	hpOld = None
	AddPower()
EndEvent

Event OnUpdateGameTime()
	;Debug.Notification("OnUpdateGameTime")
	If(iStage < flStyle.GetSize())
		PlayerRef.ChangeHeadPart(flStyle.GetAt(iStage) as HeadPart)
		If(iStage < (flStyle.GetSize() - 1))
			iStage += 1
			fUpdateFrequency = ScheduleUpdate()
			;Debug.Notification("Time until next update: " +fUpdateFrequency + " hours")
			RegisterForSingleUpdateGameTime(fUpdateFrequency)
		EndIf
	EndIf
EndEvent

Event OnRaceSwitchComplete()
	If(!UI.IsMenuOpen("RaceSex Menu"))
		If(PlayerRef.GetRace() == PlayerRace)
			Thaw()
		Else
			Freeze()
		EndIf
	EndIf
EndEvent

Float Function ScheduleUpdate()
	fLastUpdate = Utility.GetCurrentGameTime()
	;iStage += 1
	If(iStage <= 1)
		Return 24.0
	Else
		Return (iStage*24.0)
	EndIf
EndFunction

Function Freeze()
	;Debug.Notification("Freeze")
	If(fLastUpdate != 0.0)
		fTimeSinceLastUpdate = fLastUpdate - Utility.GetCurrentGameTime()
	Else
		fTimeSinceLastUpdate = ScheduleUpdate()
	EndIf
	UnregisterForUpdateGameTime()
EndFunction

Function Thaw()
	;Debug.Notification("Thaw")
	RegisterForSingleUpdateGameTime(fTimeSinceLastUpdate)
EndFunction

Function SetStyle(Int aiIndex)
	;Debug.Notification("Set style " +aiIndex)
	flStyle = flStyles[aiIndex]
	iStage = 0
	UnregisterForUpdateGameTime()
	OnUpdateGameTime()
EndFunction

Function Trim(Int aiSteps = 1)
	If(iStage > 0)
		Int i = flStyle.GetSize() - 1
		Int iIndex = 0
		Bool bFlag = False
		While((!bFlag) && (iIndex < PlayerRef.GetActorBase().GetNumHeadParts()))
			If(PlayerRef.GetActorBase().GetNthHeadPart(iIndex) == flStyle.GetAt(i) as HeadPart)
				;Debug.Notification("Beards are at " +iIndex)
				bFlag = True
			EndIf
			iIndex += 1
		EndWhile
		;Debug.Notification("i = " +i + ", iStage = " +iStage)
		If(bFlag)
			;Debug.Notification("Final stage")
			iStage -= aiSteps
		Else
			;Debug.Notification("Not final stage")
			iStage -= 2
			If(iStage < 0)
				iStage = 0
			EndIf
		EndIf
	EndIf
	;Debug.Notification("Trim to " +iStage)
	UnregisterForUpdateGameTime()
	OnUpdateGameTime()
EndFunction

Function CleanShave()
	;Debug.Notification("Clean shave")
	iStage = 0
	UnregisterForUpdateGameTime()
	OnUpdateGameTime()
EndFunction

Function AddPower()
	If(flInvalidRaces.Find(PlayerRef.GetRace()) < 0)
		If(!PlayerRef.HasSpell(kPower))
			PlayerRef.AddSpell(kPower)
		EndIf
	Else
		If(PlayerRef.HasSpell(kPower))
			PlayerRef.RemoveSpell(kPower)
		EndIf
	EndIf
EndFunction

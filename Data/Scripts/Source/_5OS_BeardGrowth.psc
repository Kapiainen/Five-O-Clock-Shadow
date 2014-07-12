Scriptname _5OS_BeardGrowth extends Quest Conditional


Bool Property bPaused Auto Hidden Conditional
Bool Property bModifiable Auto Hidden Conditional
Bool Property bModBeards Auto Hidden Conditional

_5OS_MCM Property MCM Auto
Actor Property PlayerRef Auto
Spell Property kPower Auto
MiscObject Property kRazor Auto
FormList Property flStyles Auto
FormList Property flStylesKhajiit Auto
FormList Property flVariations Auto
FormList Property flVariationsKhajiit Auto
;0 = Beard
;1 = Goatee
;2 = Horseshoe
;3 = Moustache
;4 = Muttonchops
;5 = Sideburns
;6 = Chinstrap
;7 = Goat Patch
FormList Property flKhajiitRaces Auto
FormList Property flInvalidRaces Auto
FormList Property flValidBeards Auto
Message Property _5OS_MESSAGE_Main Auto
Message Property _5OS_MESSAGE_Styles1 Auto
Message Property _5OS_MESSAGE_StylesKhajiit1 Auto
Message Property _5OS_MESSAGE_VariationsBeard Auto
Message Property _5OS_MESSAGE_VariationsGoatee Auto
Message Property _5OS_MESSAGE_VariationsGoatPatch Auto
Message Property _5OS_MESSAGE_VariationsKhajiitSideburns Auto
;Message Property _5OS_MESSAGE_VariationsKhajiitMoustache Auto

FormList flStyle
Race PlayerRace
Bool bPerformSleepUpdate
Bool bModified
Int Property iStyle = 0 Auto Hidden Conditional
Int Property iStage = 0 Auto Hidden Conditional
Float fUpdateFrequency = 2.0
Float fLastUpdate = 0.0
Float fTimeSinceLastUpdate = 0.0
Float fNextUpdate = 0.0
HeadPart hpOld = None

Event OnInit()
	RegisterForMenu("RaceSex Menu")
	PlayerRace = PlayerRef.GetRace()
	AddPower()
	;SetStyle(0)
	OnMenuOpen("RaceSex Menu")
	OnMenuClose("RaceSex Menu")
EndEvent

Event OnMenuOpen(String asMenuName)
	;Debug.Notification("Opened race menu")
	ActorBase kPlayerBase = PlayerRef.GetActorBase()
	Int iIndex = 0
	Int iSize = kPlayerBase.GetNumHeadParts()
	While(iIndex < iSize)
		HeadPart kHeadPart = kPlayerBase.GetNthHeadPart(iIndex)
		If(kHeadPart.GetType() == 4)
			hpOld = kHeadPart
			iIndex = iSize
		EndIf
		iIndex += 1
	EndWhile
	;hpOld = PlayerRef.GetActorBase().GetNthHeadPart(6)
	Freeze()
EndEvent

Event OnMenuClose(String asMenuName)
	;Debug.Notification("Closed race menu")
	PlayerRace = PlayerRef.GetRace()
	ActorBase kPlayerBase = PlayerRef.GetActorBase()
	If(flInvalidRaces.Find(PlayerRace) < 0)
		If(kPlayerBase.GetSex() == 0)
			;Debug.Notification("Male")
			;HeadPart hpNew = PlayerRef.GetActorBase().GetNthHeadPart(6)
			HeadPart hpNew = None
			Int iIndex = 0
			Int iSize = kPlayerBase.GetNumHeadParts()
			While(iIndex < iSize)
				HeadPart kHeadPart = kPlayerBase.GetNthHeadPart(iIndex)
				If(kHeadPart.GetType() == 4)
					hpNew = kHeadPart
					iIndex = iSize
				EndIf
				iIndex += 1
			EndWhile
			If(hpNew == hpOld)
				;Debug.Notification("Old facial hair")
				Thaw()
			Else
				;SetStyle(0)
				Int iTemp = IdentifyStyle()
				If(iTemp >= 0)
					If(flValidBeards.Find(hpNew) > 50)
						SetStyle(iTemp, False)
					Else
						SetStyle(iTemp)
					EndIf
				Else
					
				EndIf
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
	If(flStyle != None)
		If(iStage < flStyle.GetSize())
			PlayerRef.ChangeHeadPart(flStyle.GetAt(iStage) as HeadPart)
			Modifiable()
			If(iStage < (flStyle.GetSize() - 1))
				iStage += 1
				fUpdateFrequency = ScheduleUpdate()
				;Debug.Notification("Time until next update: " +fUpdateFrequency + " hours")
				RegisterForSingleUpdateGameTime(fUpdateFrequency)
			EndIf
		EndIf
	EndIf
EndEvent

State stSleepUpdate
	Event OnUpdateGameTime()
		If(iStage < (flStyle.GetSize() - 1))
			iStage += 1
		EndIf
		bPerformSleepUpdate = True
	EndEvent
EndState

Event OnSleepStop(Bool abInterrupted)
	Utility.Wait(0.5)
	If(bPerformSleepUpdate)
		PlayerRef.ChangeHeadPart(flStyle.GetAt(iStage) as HeadPart)
		If(iStage < (flStyle.GetSize() - 1))
			fUpdateFrequency = ScheduleUpdate()
			;Debug.Notification("Time until next update: " +fUpdateFrequency + " hours")
			RegisterForSingleUpdateGameTime(fUpdateFrequency)
		EndIf
		Modifiable()
		bPerformSleepUpdate = False
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
	Return MCM.fGrowthRate
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

Function SetStyle(Int aiIndex, Bool abUpdate = True)
	;Debug.Notification("Set style " +aiIndex)
	LetGrow()
	If(flKhajiitRaces.Find(PlayerRef.GetRace()) >= 0)
		flStyle = flStylesKhajiit.GetAt(aiIndex) as FormList
		;iStage = 0
	Else
		flStyle = flStyles.GetAt(aiIndex) as FormList
		;iStage = 0
		;From style
			;To style
				;From stage
					;To stage
		If(iStyle == 0) ;Beard
			If(aiIndex == 1) ;Chinstrap
				If(iStage > 5)
					iStage = 4
				ElseIf(iStage > 3)
					iStage = 3
				ElseIf(iStage > 1)
					iStage = 2
				Else
					iStage = 0
				EndIf
			ElseIf(aiIndex == 2) ;Goatee
				If(iStage >= 2)
					iStage = iStage - 2
				Else
					iStage = 0
				EndIf	
			ElseIf(aiIndex == 3) ;Goat Patch
				If(iStage >= 43)
					iStage = iStage - 43
				Else
					iStage = 0
				EndIf
			ElseIf(aiIndex == 4) ;Horseshoe
				If(iStage >= 28)
					iStage = iStage - 28
				Else
					iStage = 0
				EndIf
			ElseIf(aiIndex == 5) ;Moustache
				If(iStage >= 33)
					iStage = iStage - 33
				Else
					iStage = 0
				EndIf
			ElseIf(aiIndex == 6) ;Muttonchops
				If(iStage >= 25)
					iStage = (iStage/2.8) as Int
				EndIf
			ElseIf(aiIndex == 7) ;Sideburns
				If(iStage >= 25)
					iStage = (iStage/2.8) as Int
				EndIf
			EndIf
		ElseIf(iStyle == 1) ;Chinstrap
			If(aiIndex == 0) ;Beard
				If(iStage == 4)
					iStage = 6
				ElseIf(iStage == 3)
					iStage = 4
				ElseIf(iStage == 2)
					iStage = 2
				Else
					iStage = 0
				EndIf
			ElseIf(aiIndex == 2) ;Goatee
				iStage = 0
			ElseIf(aiIndex == 3) ;Goat patch
				If(iStage == 4)
					iStage = 6
				ElseIf(iStage == 3)
					iStage = 4
				ElseIf(iStage == 2)
					iStage = 2
				Else
					iStage = 0
				EndIf
			ElseIf(aiIndex == 4) ;Horseshoe
				iStage = 0
			ElseIf(aiIndex == 5) ;Moustache
				iStage = 0
			ElseIf(aiIndex == 6) ;Muttonchops
				iStage = 0
			ElseIf(aiIndex == 7) ;Sideburns
				iStage = 0
			EndIf
		ElseIf(iStyle == 2) ;Goatee
			If(aiIndex == 0) ;Beard
				iStage = 0
			ElseIf(aiIndex == 1) ;Chinstrap
				iStage = 0
			ElseIf(aiIndex == 3) ;Goat patch
				If(iStage >= 11)
					iStage = 10
				EndIf
			ElseIf(aiIndex == 4) ;Horseshoe
				If(iStage >= 14)
					iStage = 13
				EndIf
			ElseIf(aiIndex == 5) ;Moustache
				If(iStage >= 12)
					iStage = 11
				EndIf
			ElseIf(aiIndex == 6) ;Muttonchops
				iStage = 0
			ElseIf(aiIndex == 7) ;Sideburns
				iStage = 0
			EndIf
		ElseIf(iStyle == 3) ;Goat Patch
			If(aiIndex == 0) ;Beard
				iStage = 0
			ElseIf(aiIndex == 1) ;Chinstrap
				iStage = 0
			ElseIf(aiIndex == 2) ;Goatee
				iStage = 0
			ElseIf(aiIndex == 4) ;Horseshoe
				iStage = 0
			ElseIf(aiIndex == 5) ;Moustache
				iStage = 0
			ElseIf(aiIndex == 6) ;Muttonchops
				iStage = 0
			ElseIf(aiIndex == 7) ;Sideburns
				iStage = 0
			EndIf
		ElseIf(iStyle == 4) ;Horseshoe
			If(aiIndex == 0) ;Beard
				iStage = 0
			ElseIf(aiIndex == 1) ;Chinstrap
				iStage = 0
			ElseIf(aiIndex == 2) ;Goatee
				iStage = 0
			ElseIf(aiIndex == 3) ;Goat patch
				iStage = 0
			ElseIf(aiIndex == 5) ;Moustache
				If(iStage >= 12)
					iStage = 11
				EndIf
			ElseIf(aiIndex == 6) ;Muttonchops
				iStage = 0
			ElseIf(aiIndex == 7) ;Sideburns
				iStage = 0
			EndIf
		ElseIf(iStyle == 5) ;Moustache
			If(aiIndex == 0) ;Beard
				iStage = 0
			ElseIf(aiIndex == 1) ;Chinstrap
				iStage = 0
			ElseIf(aiIndex == 2) ;Goatee
				iStage = 0
			ElseIf(aiIndex == 3) ;Goat patch
				iStage = 0
			ElseIf(aiIndex == 4) ;Horseshoe
				If(iStage >= 5)
					iStage = 4
				EndIf
			ElseIf(aiIndex == 6) ;Muttonchops
				iStage = 0
			ElseIf(aiIndex == 7) ;Sideburns
				iStage = 0
			EndIf
		ElseIf(iStyle == 6) ;Muttonchops
			If(aiIndex == 0) ;Beard
				iStage = 0
			ElseIf(aiIndex == 1) ;Chinstrap
				iStage = 0
			ElseIf(aiIndex == 2) ;Goatee
				iStage = 0
			ElseIf(aiIndex == 3) ;Goat patch
				iStage = 0
			ElseIf(aiIndex == 4) ;Horseshoe
				If(iStage > 13)
					iStage = 13
				EndIf
			ElseIf(aiIndex == 5) ;Moustache
				If(iStage > 11)
					iStage = 11
				EndIf
			ElseIf(aiIndex == 7) ;Sideburns
				;
			EndIf
		ElseIf(iStyle == 7) ;Sideburns
			If(aiIndex == 0) ;Beard
				iStage = 0
			ElseIf(aiIndex == 1) ;Chinstrap
				iStage = 0
			ElseIf(aiIndex == 2) ;Goatee
				iStage = 0
			ElseIf(aiIndex == 3) ;Goat patch
				iStage = 0
			ElseIf(aiIndex == 4) ;Horseshoe
				iStage = 0
			ElseIf(aiIndex == 5) ;Moustache
				iStage = 0
			ElseIf(aiIndex == 6) ;Muttonchops
				iStage = 0
			EndIf
		EndIf
	EndIf
	iStyle = aiIndex
	UnregisterForUpdateGameTime()
	If(abUpdate)
		OnUpdateGameTime()
		If(MCM.bUpdateOnWakeUp)
			OnSleepStop(False)
		EndIf
	Else
		Maintain()
	EndIf
EndFunction

Function Trim(Int aiSteps = 1)
	LetGrow()
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
	If(GetState() == "")
		OnUpdateGameTime()
	Else
		PlayerRef.ChangeHeadPart(flStyle.GetAt(iStage) as HeadPart)
		fUpdateFrequency = ScheduleUpdate()
		;Debug.Notification("Time until next update: " +fUpdateFrequency + " hours")
		RegisterForSingleUpdateGameTime(fUpdateFrequency)
	EndIf
EndFunction

Function CleanShave()
	LetGrow()
	;Debug.Notification("Clean shave")
	iStage = 0
	UnregisterForUpdateGameTime()
	If(GetState() == "")
		OnUpdateGameTime()
	Else
		PlayerRef.ChangeHeadPart(flStyle.GetAt(iStage) as HeadPart)
		fUpdateFrequency = ScheduleUpdate()
		;Debug.Notification("Time until next update: " +fUpdateFrequency + " hours")
		RegisterForSingleUpdateGameTime(fUpdateFrequency)
	EndIf
EndFunction

Function AddPower()
	If(flInvalidRaces.Find(PlayerRef.GetRace()) < 0)
		If(MCM.bPower)
			If(!PlayerRef.HasSpell(kPower))
				PlayerRef.AddSpell(kPower)
			EndIf
		Else
			If(PlayerRef.GetItemCount(kRazor) == 0)
				PlayerRef.AddItem(kRazor)
			EndIf
		EndIf
	Else
		If(PlayerRef.HasSpell(kPower))
			PlayerRef.RemoveSpell(kPower)
		EndIf
		Int iCount = PlayerRef.GetItemCount(kRazor)
		If(iCount > 0)
			PlayerRef.RemoveItem(kRazor, iCount)
		EndIf
	EndIf
EndFunction

Function Maintain()
	bPaused = True
	UnregisterForUpdateGameTime()
EndFunction

Function LetGrow()
	bPaused = False
	If(bModified)
		If(GetState() == "stSleepUpdate")
			GoToState("")
			OnUpdateGameTime()
			GoToState("stSleepUpdate")
		Else
			OnUpdateGameTime()
		EndIf
	Else
		RegisterForSingleUpdateGameTime(ScheduleUpdate())
	EndIf
	bModified = False
EndFunction

Int Function IdentifyStyle()
	FormList flFormList = None
	HeadPart kHeadPart = None
	ActorBase kPlayerBase = PlayerRef.GetActorBase()
	Int iIndex = 0
	Int iSize = kPlayerBase.GetNumHeadParts()
	Int iBeardSlot = -1
	While(iIndex < iSize)
		kHeadPart = kPlayerBase.GetNthHeadPart(iIndex)
		If(kHeadPart.GetType() == 4)
			If(flValidBeards.Find(kHeadPart) >= 0)
				iBeardSlot = iIndex
				iIndex = 0
				FormList aflStyles = None
				FormList aflVariations = None
				If(flKhajiitRaces.Find(PlayerRef.GetRace()) >= 0)
					aflStyles = flStylesKhajiit
					aflVariations = flVariationsKhajiit
				Else
					aflStyles = flStyles
					aflVariations = flVariations
				EndIf
				iSize = aflStyles.GetSize()
				While(iIndex < iSize)
					Int iTemp = (aflStyles.GetAt(iIndex) as FormList).Find(kPlayerBase.GetNthHeadPart(iBeardSlot))
					If(iTemp >= 0)
						;Debug.Notification("Correctly identified the beard")
						iStage = iTemp
						Return iIndex
					EndIf
					iTemp = (aflVariations.GetAt(iIndex) as FormList).Find(kPlayerBase.GetNthHeadPart(iBeardSlot))
					If(iTemp >= 0)
						If(aflStyles == flStylesKhajiit)
							iStage = 18
						Else
							;Debug.Notification("Correctly identified variation")
							iStage = 0
							If(iIndex == 0)
								If(iTemp < 2)
									iStage = 11
								EndIf
							ElseIf(iIndex == 1)
							ElseIf(iIndex == 2)
								If(bModBeards)
									If(iTemp < 4)
										iStage = 12
									ElseIf(iTemp < 6 )
										iStage = 7
									Else
										iStage = 16
									EndIf
								EndIf
							ElseIf(iIndex == 3)
								If(iTemp == 0)
									iStage = 10
								EndIf
							ElseIf(iIndex == 4)
							ElseIf(iIndex == 5)
							ElseIf(iIndex == 6)
							ElseIf(iIndex == 7)
							EndIf
						EndIf
						Return iIndex
					EndIf
					iIndex += 1
				EndWhile
			EndIf
		EndIf
		kHeadPart = None
		iIndex += 1
	EndWhile
	;Debug.Notification("Unknown beard")
	Return -1
EndFunction

Function ConfigMenu()
	Bool bFlag = False
	While(!bFlag)
		Int iChoice = _5OS_MESSAGE_Main.Show()
		If(iChoice == 0) ;Trim
			Trim()
		ElseIf(iChoice == 1) ;Clean shave
			CleanShave()
		ElseIf(iChoice == 2) ;Maintain
			Maintain()
		ElseIf(iChoice == 3) ;Let grow
			LetGrow()
		ElseIf(iChoice == 4) ;Modify
			If(flKhajiitRaces.Find(PlayerRef.GetRace()) >= 0)
				If(iStyle == 0)
					iChoice = _5OS_MESSAGE_VariationsKhajiitSideburns.Show()
					If(iChoice < 2)
						SetModification(iChoice, 18, True)
					Else ;Back
					
					EndIf
				EndIf
			Else
				If(iStyle == 0)
					iChoice = _5OS_MESSAGE_VariationsBeard.Show()
					If(iChoice < 2)
						SetModification(iChoice, 38)
					Else ;Back
						
					EndIf
				ElseIf(iStyle == 1)
					
				ElseIf(iStyle == 2)
					iChoice = _5OS_MESSAGE_VariationsGoatee.Show()
					If(iChoice == 0) ;Knot
						SetModification(0, 13)
					ElseIf(iChoice == 1) ;Double braid
						SetModification(1, 12)
					ElseIf(iChoice == 2) ;Triple braid
						SetModification(2, 12)
					ElseIf(iChoice == 3) ;Quintuple braid
						SetModification(3, 12)
					ElseIf(iChoice == 4) ;Braided short moustache
						SetModification(4, 7)
					ElseIf(iChoice == 5) ;Braided long moustache
						SetModification(5, 7)
					ElseIf(iChoice == 6) ;Tied
						SetModification(6, 16)
					Else ;Back
						
					EndIf
				ElseIf(iStyle == 3)
					iChoice = _5OS_MESSAGE_VariationsGoatPatch.Show()
					If(iChoice == 0) ;Tied
						SetModification(0, 10)
					Else ;Back
						
					EndIf
				ElseIf(iStyle == 4)
					
				ElseIf(iStyle == 5)
					
				ElseIf(iStyle == 6)
					
				ElseIf(iStyle == 7)
					
				EndIf
			EndIf
		ElseIf(iChoice == 5)
			If(flKhajiitRaces.Find(PlayerRef.GetRace()) >= 0)
				iChoice = _5OS_MESSAGE_StylesKhajiit1.Show()
				If(iChoice < 2)
					SetStyle(iChoice)
				Else
					;Back
				EndIf
			Else
				iChoice = _5OS_MESSAGE_Styles1.Show()
				If(iChoice < 8)
					SetStyle(iChoice)
				Else
					;Back
				EndIf
			EndIf
		ElseIf(iChoice == 6) ;Exit
			bFlag = True
		EndIf
	EndWhile
EndFunction

Function SetModification(Int aiIndex, Int aiStage, Bool abKhajiit = False)
	Maintain()
	iStage = aiStage
	If(abKhajiit)
	PlayerRef.ChangeHeadPart((flVariationsKhajiit.GetAt(iStyle) as FormList).GetAt(aiIndex) as HeadPart)
	Else
		PlayerRef.ChangeHeadPart((flVariations.GetAt(iStyle) as FormList).GetAt(aiIndex) as HeadPart)
	EndIf
	bModified = True
EndFunction

Function Modifiable()
	If(flKhajiitRaces.Find(PlayerRef.GetRace()) >= 0)
		If(iStyle == 0) ;Sideburns
			If(iStage >= 53)
				bModifiable = True
			Else
				bModifiable = False
			EndIf
		EndIf
	Else
		If(iStyle == 0) ;Beard
			If(iStage >= 15)
				bModifiable = True
			Else
				bModifiable = False
			EndIf
		ElseIf(iStyle == 1) ;Chinstrap
			bModifiable = False
		ElseIf(iStyle == 2) ;Goatee
			If(((iStage > 11) && (bModBeards)) || (iStage > 12))
				bModifiable = True
			Else
				bModifiable = False
			EndIf
		ElseIf(iStyle == 3) ;Goat patch
			If(iStage >= 10)
				bModifiable = True
			Else
				bModifiable = False
			EndIf
		ElseIf(iStyle == 4) ;Horseshoe
			bModifiable = False
		ElseIf(iStyle == 5) ;Moustache
			bModifiable = False
		ElseIf(iStyle == 6) ;Muttonchops
			bModifiable = False
		ElseIf(iStyle == 7) ;Sideburns
			bModifiable = False
		EndIf
	EndIf
EndFunction

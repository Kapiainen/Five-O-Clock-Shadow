Scriptname _5OS_Script_FollowerAlias extends ReferenceAlias  

;##########################################################################################################################################
;Variables
;##########################################################################################################################################

	Int iDefaultStyle = 0
	Int iDefaultLength = 0
	Int iDefaultStage = 0
	Int iCurrentStyle = 0
	Int iCurrentLength = 0
	Int iCurrentStage = 0

	Float fHoursInInn = 0.0

	;Float fGameTimeFrequency = 24.0 ;Replace with GlobVar

	FormList flCurrentLength
	FormList flCurrentStyle
	HeadPart hpCurrentStage

	FormList Property flStylesMaster Auto
	Spell Property kAbility Auto
	Spell Property kAbilityIncompatible Auto
	Actor Property PlayerRef Auto
	GlobalVariable Property gvGameTimeFrequency Auto

	Actor kFollower
	Float fPreviousSwitch
	Float fDeltaPreviousSwitch

;##########################################################################################################################################
;Events
;##########################################################################################################################################

	Event OnPlayerLoadGame()
		;fGameTimeFrequency = gvGameTimeFrequency.GetValue()
		If((hpCurrentStage) && (kFollower))
			kFollower.ChangeHeadPart(hpCurrentStage)
			Utility.GetCurrentGameTime() - fPreviousSwitch
		EndIf
	EndEvent

	Event OnUpdateGameTime()
		If(UI.IsMenuOpen("Dialogue Menu")) ;Player is talking to an NPC(, check periodically to see if the player is still talking to an NPC)
			RegisterForMenu("Dialogue Menu")
		Else ;HeadPart can be switched safely
			While(PlayerRef.HasLOS(kFollower))
				Utility.WaitMenuMode(10.0)
			EndWhile
			If(SwitchToNextHeadPart()) ;Successfully switched to next HeadPart
				ScheduleSwitch()
			Else ;At the end of the current FormList
				
			EndIf
		EndIf
	EndEvent

	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		;Debug.Notification("OnLocationChange")
		If(akNewLoc)
			If((akNewLoc.HasKeywordString("LocTypeInn")) || (akNewLoc.HasKeywordString("LocTypePlayerHouse")))
				RegisterForSleep()
			Else
				UnregisterForSleep()
			EndIf
		EndIf
	EndEvent

	Event OnMenuClose(String asParam)
		If(asParam == "Dialogue Menu")
			UnregisterForMenu("Dialogue Menu")
			If(SwitchToNextHeadPart()) ;Successfully switched to next HeadPart
				ScheduleSwitch()
			Else ;At the end of the current FormList, no need to register again
				
			EndIf
		EndIf
	EndEvent

	Event OnRaceSwitchComplete() ;For when the follower transforms into a werewolf or Vampire Lord
		If((kFollower.GetRace() == Game.GetFormFromFile(0x000CDD84, "Skyrim.esm") as Race) || (kFollower.GetRace() == Game.GetFormFromFile(0x0200283A, "Dawnguard.esm") as Race))
			UnregisterForUpdateGameTime()
			fDeltaPreviousSwitch = Utility.GetCurrentGameTime() - fPreviousSwitch
		Else
			UnregisterForUpdateGameTime()
			Float fTime = gvGameTimeFrequency.GetValue() - fDeltaPreviousSwitch*24.0
			If(fTime < 0.05)
				OnUpdateGameTime()
			Else
				RegisterForSingleUpdateGameTime(fTime)
			EndIf
		EndIf
	EndEvent

	Event OnSleepStop(bool abInterrupted)
		;Debug.Notification("OnSleepStop")
		Shave()
	EndEvent

	State Restore
		Event OnUpdateGameTime()
			If((!PlayerRef.HasLOS(kFollower)) && (PlayerRef.GetParentCell() != kFollower.GetParentCell()))
				;Debug.Notification("Restoring facial hair")
				Restore()
			Else
				RegisterForSingleUpdateGameTime(1.0)
			EndIf
		EndEvent
	EndState

;##########################################################################################################################################
;Functions
;##########################################################################################################################################

	Function SettingChange()
		UnregisterForUpdateGameTime()
		Float fTime = (Utility.GetCurrentGameTime() - fPreviousSwitch)*24.0
		If(fTime < 0.05)
			OnUpdateGameTime()
		Else
			ScheduleSwitch()
		EndIf
	EndFunction

	Function Start()
		;fGameTimeFrequency = gvGameTimeFrequency.GetValue()
		CleanUp()
		fPreviousSwitch = Utility.GetCurrentGameTime()
		kFollower = Self.GetActorReference()
		;Debug.Notification("Start")
		IdentifyBeard()
	EndFunction

	Function Stop()
		;Debug.Notification("Stop")
		GoToState("Restore")
		UnregisterForUpdateGameTime()
		RegisterForSingleUpdateGameTime(1.0)
	EndFunction

	Function Die()
		;Debug.Notification("Die")
		CleanUp()
		Self.Clear()
	EndFunction

	Function Restore()
		Shave()
		CleanUp()
		Self.Clear()
	EndFunction

	Function CleanUp()
		;Debug.Notification("CleanUp")
		flCurrentStyle = None
		flCurrentLength = None
		hpCurrentStage = None
		kFollower = None
		iDefaultStyle = 0
		iDefaultLength = 0
		iDefaultStage = 0
		UnregisterForUpdateGameTime()
		UnregisterForAllMenus()
		UnregisterForSleep()
		GoToState("")
	EndFunction

	Function Shave()
		SetNthStage(iDefaultStage)
	EndFunction

	Function IdentifyBeard()
		Int iBeardIndex = -1
			Int iIndex = kFollower.GetActorBase().GetNumHeadParts()
			;Debug.Notification("Max iIndex = " + iIndex)
			While(iIndex >= 0)
				iIndex -= 1
				;Debug.Notification("iIndex = " + iIndex + " -> " + kFollower.GetActorBase().GetNthHeadPart(iIndex).GetName())
				If(kFollower.GetActorBase().GetNthHeadPart(iIndex).GetType() == 4)
					iBeardIndex = iIndex
					iIndex = -1 ;QUESTIONABLE
				EndIf
			EndWhile
			
			;Debug.Notification("iBeardIndex = " + iBeardIndex)
			If(iBeardIndex >= 0)
				HeadPart hpCandidate = kFollower.GetActorBase().GetNthHeadPart(iBeardIndex) as HeadPart
				;Debug.Notification("Beard: " + hpCandidate.GetName())
				Int iMax = flStylesMaster.GetSize()
				Int i = 0
				;Debug.Notification("Max i = " + i)
				While(i < iMax)
					;Debug.Notification("i = " + i)
					FormList flIdentifyStyle = flStylesMaster.GetAt(i) as FormList
					Int jMax = flIdentifyStyle.GetSize()
					Int j = 0
					;Debug.Notification("Max j = " + j)
					While(j < jMax)
						;Debug.Notification("j = " + j)
						FormList flIdentifyLength = flIdentifyStyle.GetAt(j) as FormList
						Int k = flIdentifyLength.Find(hpCandidate)
						;Debug.Notification("Max k = " + k)
						If(k >= 0)
							;Debug.Notification("Final: i = " + i + ", j = " + j + ", k = " + k)
							SetNthStyle(i)
							SetNthLength(j)
							If(SetHeadPart(flCurrentLength.GetAt(k) as HeadPart))
								ScheduleSwitch()
								;Debug.Notification("Successfully set identified HeadPart")
								iDefaultStyle = i
								iDefaultLength = j
								iDefaultStage = k
								;Debug.Notification("Style = " + iDefaultStyle + ", length = " + iDefaultLength + ", stage = " + iDefaultStage)
								Return
							Else
								;Debug.Notification("Failed to set identified HeadPart")
								Return
							EndIf
						EndIf
						j += 1
					EndWhile
					i += 1
				EndWhile
				;Debug.Notification("Failed to identify Facial Hair")
				kFollower.AddSpell(kAbilityIncompatible, False)
				CleanUp()
				Self.Clear()
				Return
			EndIf
	EndFunction

	Bool Function SetNthStyle(Int aiParam)
		If((aiParam >= 0) && (aiParam < flStylesMaster.GetSize()))
			iCurrentStyle = aiParam
			FormList flCandidate = flStylesMaster.GetAt(aiParam) as FormList
			If(flCandidate)
				flCurrentStyle = flCandidate
				Return True
			Else
				Return False
			EndIf
		EndIf
	EndFunction

	Bool Function SetNthLength(Int aiParam)
		If((aiParam >= 0) && (aiParam < flCurrentStyle.GetSize()))
			iCurrentLength = aiParam
			FormList flCandidate = flCurrentStyle.GetAt(aiParam) as FormList
			If(flCandidate)
				flCurrentLength = flCandidate
				Return True
			Else
				Return False
			EndIf
		Else
			Return False
		EndIf
	EndFunction

	Bool Function SetNthStage(Int aiParam)
		If((aiParam >= 0) && (aiParam < flCurrentLength.GetSize()))
			iCurrentStage = aiParam
			HeadPart hpCandidate = flCurrentLength.GetAt(iCurrentStage) as HeadPart
			If(hpCandidate)
				If(SetHeadPart(hpCandidate))
					ScheduleSwitch()
					Return True
				Else
					Return False
				EndIf
			Else
				Return False
			EndIf
		EndIf
	EndFunction

	Bool Function SetHeadPart(HeadPart ahpParam)
		If(ahpParam)
			hpCurrentStage = ahpParam
			kFollower.ChangeHeadPart(hpCurrentStage)
			fPreviousSwitch = Utility.GetCurrentGameTime()
			ScheduleSwitch()
			Return True
		Else
			Return False
		EndIf
	EndFunction

	Function ScheduleSwitch()
		RegisterForSingleUpdateGameTime(gvGameTimeFrequency.GetValue())
	EndFunction

	Bool Function SwitchToNextHeadPart()
		HeadPart hpCandidate = GetNextHeadPart(flCurrentLength)
		If(hpCandidate)
			Return SetHeadPart(hpCandidate)
		Else
			Return False
		EndIf
	EndFunction

	HeadPart Function GetNextHeadPart(FormList aflParam = None)
		If(aflParam == None)
			aflParam = flCurrentLength
		EndIf
		If(aflParam != None)
			Int iIndex = aflParam.Find(hpCurrentStage)
			Int iSize = aflParam.GetSize()
			If(iIndex < (iSize - 1))
				If(iIndex >= 0)
					iIndex += 1
					Return aflParam.GetAt(iIndex) as HeadPart
				Else ;iIndex < 0
					Return None
				EndIf
			Else ;iIndex >= iSize - 1
				Return None
			EndIf
		Else
			Return None
		EndIf
	EndFunction
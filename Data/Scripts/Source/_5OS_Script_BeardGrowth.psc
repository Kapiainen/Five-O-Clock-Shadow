Scriptname _5OS_Script_BeardGrowth extends Quest Conditional

Actor Property PlayerRef Auto

;Settings and states
Bool Property bGrowing = True Auto Hidden Conditional ;True when beard can grow, false when the beard is maintained at its current stage
Bool Property bSleepOnly = False Auto Hidden Conditional ;Only update when sleeping
Bool bFrozen = False ;True when beard growth is temporarily frozen

;Step frequency
Float Property fGameTimeFrequency = 24.0 Auto Conditional ;Replace with GlobVar
GlobalVariable Property gvGameTimeFrequency Auto

;Messages
Message Property msgInit Auto

;Style, length, and stage
FormList Property flStylesMaster Auto ;Contains sub-FormLists that themselves contain either sub-FormLists or HeadParts
Int Property iCurrentStyle = 0 Auto Hidden Conditional
Int Property iCurrentLength = 0 Auto Hidden Conditional
Int Property iCurrentStage = 0 Auto Hidden Conditional
FormList flCurrentStyle
FormList flCurrentLength
HeadPart hpCurrentStage

;Time
Float fPreviousSwitch
Float fDeltaPreviousSwitch

;Audiovisual representation
Bool Property bCutScene = True Auto Conditional
Spell Property kFollowerCloak Auto
Spell Property kFollowerAbility Auto

;Misc
Bool Property bBrawlBugFix = True Auto Conditional

;Version information
Int iScriptVersion = 0

Int Function GetVersion()
	Return 4
EndFunction

;###################################################################################################################################################################################################################################
;Events

	Event OnInit()
		UnregisterForUpdate()
		RegisterForSingleUpdate(2.0)
	EndEvent

	Event OnVersionUpdate(Int aiNewScriptVersion)
		;Initial release
		If((aiNewScriptVersion >= 1) && (iScriptVersion < 1))
			Debug.Trace("===== Initializing 'Five O'Clock Shadow' 3.0.0 =====")
			InitMod()
			Create_2D()
			SetValues_2D()
		EndIf

		If((aiNewScriptVersion >= 2) && (iScriptVersion < 2))
			Debug.Trace("===== Updating 'Five O'Clock Shadow' to version 3.0.1 =====")
			If(PlayerRef.HasKeywordString("IsBeastRace"))
				GoToState("Female")
				UnregisterForSleep()
				UnregisterForUpdateGameTime()
				UnregisterForAllMenus()
			EndIf
		EndIf

		If((aiNewScriptVersion >= 3) && (iScriptVersion < 3))
			Debug.Trace("===== Updating 'Five O'Clock Shadow' to version 3.0.2 =====")
			SetValues_2D() ;Added a new length to beard style
			If(hpCurrentStage) ;If a facial hair has been identified
				If(iCurrentStyle == 0) ;If the player is currently in the beard style
					If(iCurrentLength >= 1) ;If the player is in one of the non-shared lengths
						;Debug.Trace("Adjusting full beard length from " + iCurrentLength + " to " + (iCurrentLength + 1))
						SetNthLength(iCurrentLength + 1) ;Adjust the length
					EndIf
				EndIf
			EndIf
		EndIf

		If((aiNewScriptVersion >= 4) && (iScriptVersion < 4))
			Debug.Trace("===== Updating 'Five O'Clock Shadow' to version 3.0.3 =====")
			
		EndIf

		iScriptVersion = aiNewScriptVersion
	EndEvent

	Event OnUpdate()
		OnVersionUpdate(GetVersion())
	EndEvent

	Event OnPlayerLoadGame()
		fGameTimeFrequency = gvGameTimeFrequency.GetValue()
		OnVersionUpdate(GetVersion())
	EndEvent

	Event OnUpdateGameTime()
		If(UI.IsMenuOpen("Dialogue Menu")) ;Player is talking to an NPC(, check periodically to see if the player is still talking to an NPC)
			RegisterForMenu("Dialogue Menu")
		Else ;HeadPart can be switched safely
			If(SwitchToNextHeadPart()) ;Successfully switched to next HeadPart
				ScheduleSwitch(False)
			Else ;At the end of the current FormList
				
			EndIf
		EndIf
	EndEvent

	Event OnSleepStop(Bool abInterrupted)
		If((bGrowing) && (bSleepOnly))
			If(((Utility.GetCurrentGameTime() - fPreviousSwitch)*24.0) >= gvGameTimeFrequency.GetValue())
				SwitchToNextHeadPart()
			Else
				
			EndIf
		Else
			
		EndIf
	EndEvent

	Event OnRaceSwitchComplete()
		If(!UI.IsMenuOpen("RaceSex Menu"))
			If(PlayerRef.GetActorBase().GetSex() == 0)
				If((PlayerRef.GetRace() == Game.GetFormFromFile(0x000CDD84, "Skyrim.esm") as Race) || (PlayerRef.GetRace() == Game.GetFormFromFile(0x0200283A, "Dawnguard.esm") as Race))
					Freeze() ;Player transformed into a werewolf or Vampire Lord -> Stop growth
				Else
					If((bFrozen) && (!bSleepOnly) && (bGrowing))
						Thaw() ;Player transformed into a race that is not a werewolf nor a Vampire Lord -> Continue growth
					EndIf
				EndIf
			Else
				Freeze()
			EndIf
		EndIf
	EndEvent


	Event OnMenuClose(String asParam)
		If(asParam == "RaceSex Menu")
			Int iChoice = msgInit.Show()
			If(iChoice == 0) ;Done
				UnregisterForMenu("RaceSex Menu")
				IdentifyBeard()
			EndIf
		ElseIf(asParam == "Dialogue Menu")
			UnregisterForMenu("Dialogue Menu")
			If(SwitchToNextHeadPart()) ;Successfully switched to next HeadPart
				ScheduleSwitch(False)
			Else ;At the end of the current FormList, no need to register again
				
			EndIf
		EndIf
	EndEvent

	State Female
		Event OnUpdateGameTime()
		EndEvent

		Event OnSleepStop(Bool abInterrupted)
		EndEvent

		Event OnRaceSwitchComplete()
		EndEvent

		Event OnMenuOpen(String asParam)
		EndEvent

		Event OnMenuClose(String asParam)
		EndEvent
	EndState

;###################################################################################################################################################################################################################################
;Functions

	Function InitMod()
		;Debug.Trace("5OS -> InitMod()")
		Int iChoice = msgInit.Show()
		If(iChoice == 0) ;After CC
			IdentifyBeard()
		Else ;Before CC
			RegisterForMenu("RaceSex Menu")
		EndIf
		RegisterForSleep()
	EndFunction

	Function IdentifyBeard()
		;Debug.Trace("5OS -> IdentifyBeard()")
		If((PlayerRef.GetActorBase().GetSex() == 0) && (!PlayerRef.HasKeywordString("IsBeastRace")))
			Int iBeardIndex = -1
			Int iIndex = PlayerRef.GetActorBase().GetNumHeadParts()
			;Debug.Trace("5OS -> Max iIndex = " + iIndex)
			While(iIndex >= 0)
				iIndex -= 1
				;Debug.Trace("5OS -> iIndex = " + iIndex + " -> " + PlayerRef.GetActorBase().GetNthHeadPart(iIndex).GetName())
				If(PlayerRef.GetActorBase().GetNthHeadPart(iIndex).GetType() == 4)
					iBeardIndex = iIndex
					iIndex = -1 ;QUESTIONABLE
				EndIf
			EndWhile
			
			;Debug.Trace("5OS -> iBeardIndex = " + iBeardIndex)
			If(iBeardIndex >= 0)
				HeadPart hpCandidate = PlayerRef.GetActorBase().GetNthHeadPart(iBeardIndex) as HeadPart
				;Debug.Trace("5OS -> Beard: " + hpCandidate.GetName())
				Int iMax = flStylesMaster.GetSize()
				Int i = 0
				;Debug.Trace("5OS -> Max i = " + i)
				While(i < iMax)
					;Debug.Trace("5OS -> i = " + i)
					FormList flIdentifyStyle = flStylesMaster.GetAt(i) as FormList
					Int jMax = flIdentifyStyle.GetSize()
					Int j = 0
					;Debug.Trace("5OS -> Max j = " + j)
					While(j < jMax)
						;Debug.Trace("5OS -> j = " + j)
						FormList flIdentifyLength = flIdentifyStyle.GetAt(j) as FormList
						Int k = flIdentifyLength.Find(hpCandidate)
						;Debug.Trace("5OS -> Max k = " + k)
						If(k >= 0)
							;Debug.Trace("5OS -> Final: i = " + i + ", j = " + j + ", k = " + k)
							SetNthStyle(i)
							SetNthLength(j)
							If(SetHeadPart(flCurrentLength.GetAt(k) as HeadPart))
								ScheduleSwitch(False)
								;Debug.Trace("5OS -> Successfully set identified HeadPart")
								Return
							Else
								;Debug.Trace("5OS -> Failed to set identified HeadPart")
								Return
							EndIf
						EndIf
						j += 1
					EndWhile
					i += 1
				EndWhile
				;Debug.Trace("5OS -> Failed to identify Facial Hair")
				Return
			EndIf
			;Debug.Trace("5OS -> Failed to identify Facial Hair slot")
		Else
			;Debug.Trace("5OS -> Female character")
			GoToState("Female")
			UnregisterForSleep()
			UnregisterForUpdateGameTime()
			UnregisterForAllMenus()
		EndIf
	EndFunction

	Function ModFrequency(Float afParam)
		If(afParam < 0.0)
			If(fGameTimeFrequency + afParam >= 1.0)
				fGameTimeFrequency += afParam
			EndIf
		ElseIf(afParam > 0.0)
			fGameTimeFrequency += afParam
		EndIf
		gvGameTimeFrequency.SetValue(fGameTimeFrequency)
		(Self.GetNthAlias(0) as _5OS_Script_PlayerAlias).SettingChange()
		If((!bSleepOnly) && (!bFrozen) && (bGrowing))
			Float fTime = gvGameTimeFrequency.GetValue() - (Utility.GetCurrentGameTime() - fPreviousSwitch)*24.0
			If(fTime < 0.05)
				OnUpdateGameTime()
			Else
				ScheduleSwitch(True, fTime)
			EndIf
		EndIf
	EndFunction

	Function Maintain()
		bGrowing = False
		UnregisterForUpdateGameTime()
	EndFunction

	Function LetGrow()
		bGrowing = True
		SetPreviousSwitch()
		ScheduleSwitch(False)
	EndFunction

	Function FadeOut(Float afDuration)
		If(bCutScene)
			ImageSpaceModifier kIMODFadeToBlackHold = Game.GetFormFromFile(0x000F756E, "Skyrim.esm") as ImageSpaceModifier
			kIMODFadeToBlackHold.ApplyCrossFade(afDuration)
			Utility.WaitMenuMode(afDuration)
		EndIf
	EndFunction

	Function FadeIn(Float afDuration)
		If(bCutScene)
			ImageSpaceModifier.RemoveCrossfade(afDuration)
			Utility.WaitMenuMode(afDuration)
		EndIf
	EndFunction

	Function PlaySound(Int aiFormID, String asPluginName = "Five O'Clock Shadow.esp")
		If(bCutScene)
			Sound kSound = Game.GetFormFromFile(aiFormID, asPluginName) as Sound
			kSound.PlayAndWait(PlayerRef)
		EndIf
	EndFunction

	Function CleanShave()
		Game.DisablePlayerControls()
		FadeOut(0.5)
		PlaySound(0x0200B234)

		SetNthLength(0)
		SetNthStage(0)

		FadeIn(0.5)
		Game.EnablePlayerControls()
	EndFunction

	Function TrimLength()
		Int iIndex = GetCurrentStage()
		If(iIndex == 0)
			Game.DisablePlayerControls()
			FadeOut(0.5)
			PlaySound(0x0200B238)

			SetNthLength(iCurrentLength - 1)
			HeadPart hpCandidate = flCurrentLength.GetAt(0) as HeadPart
			If(hpCandidate)
				If(SetHeadPart(hpCandidate))
					ScheduleSwitch(False)
				EndIf
			EndIf

			FadeIn(0.5)
			Game.EnablePlayerControls()
		ElseIf(iIndex > 0)
			Game.DisablePlayerControls()
			FadeOut(0.5)
			PlaySound(0x0200B238)

			HeadPart hpCandidate = flCurrentLength.GetAt(0) as HeadPart
			If(hpCandidate)
				If(SetHeadPart(GetPreviousHeadPart()))
					ScheduleSwitch(False)
				EndIf
			EndIf

			FadeIn(0.5)
			Game.EnablePlayerControls()
		Else
			CleanShave()
		EndIf
	EndFunction

	Function ScheduleSwitch(Bool abThaw, Float afTime = 0.0)
		UnregisterForUpdateGameTime()
		If((bGrowing) && (!bSleepOnly))
			If(abThaw)
				RegisterForSingleUpdateGameTime(afTime)
			Else
				RegisterForSingleUpdateGameTime(gvGameTimeFrequency.GetValue())
			EndIf
		EndIf
	EndFunction

	Function TrimStyle()
		;Debug.Trace("5OS -> TrimStyle()")
		;Figure out the longest style that is applicable
		Int[] iThresholds = GetArrayFromID(iCurrentStyle) ;Get the length thresholds of the current style
		Int iIndex = iThresholds.Length ;Get the size of the length threshold array
		Int iCurrentIndex = GetCurrentStage() ;Get the index of the current HeadPart in the current length of the current style
		FormList flBaseStage = flCurrentStyle.GetAt(0) as FormList ;Get the base length FormList
		Bool bFound = False
		;Debug.Trace("5OS -> iCurrentIndex = " + iCurrentIndex)
		While(!bFound)
			iIndex -= 1
			;Debug.Trace("5OS -> iIndex = " + iIndex)
			If(iIndex < 0)
				;Debug.Trace("5OS -> Couldn't find a style")
				Return
			EndIf
			If(iThresholds[iIndex] >= 0) ;Start checking in reverse order for the first non-negative (actual) threshold
				HeadPart hpThreshold = flBaseStage.GetAt(iThresholds[iIndex]) as HeadPart ;Get the corresponding HeadPart from the base length FormList
				Int iPosition = flCurrentLength.Find(hpThreshold)
				;Debug.Trace("5OS -> iPosition = " + iPosition)
				If((iPosition >= 0) && (iPosition <= iCurrentIndex)) ;Check if the threshold HeadPart is located below or exactly at the current index in the current length of the current style
					Game.DisablePlayerControls()
					FadeOut(0.5)
					PlaySound(0x0200B237)

					bFound = True
					SetNthLength(iIndex)
					;Debug.Trace("5OS -> Setting length to " + iIndex)
					If(SetHeadPart(flCurrentLength.GetAt(0) as HeadPart)) ;The longest possible length of the style has been found, so set it
						ScheduleSwitch(False)
					EndIf

					FadeIn(0.5)
					Game.EnablePlayerControls()
				Else
					If((iCurrentLength == 0) && (iIndex > 0))
						bFound = False
					Else
						;hpThreshold = None
						;Debug.Trace("5OS -> Staying at current length")
						Game.DisablePlayerControls()
						FadeOut(0.5)
						PlaySound(0x0200B237)

						bFound = True
						If(SetHeadPart(flCurrentLength.GetAt(0) as HeadPart)) ;The longest possible length of the style has been found, so set it
							ScheduleSwitch(False)
						EndIf

						FadeIn(0.5)
						Game.EnablePlayerControls()
					EndIf
				EndIf
			EndIf
		EndWhile
	EndFunction

	Function SleepOnly(Bool abParam = True)
		If(abParam)
			bSleepOnly = True
			Freeze()
		Else
			bSleepOnly = False
			SetPreviousSwitch()
			Thaw()
		EndIf
	EndFunction

	Function Freeze()
		bFrozen = True
		UnregisterForUpdateGameTime()
		fDeltaPreviousSwitch = Utility.GetCurrentGameTime() - fPreviousSwitch
	EndFunction

	Function Thaw()
		bFrozen = False
		Float fTime = gvGameTimeFrequency.GetValue() - fDeltaPreviousSwitch*24.0
		If(fTime < 0.05)
			OnUpdateGameTime()
		Else
			ScheduleSwitch(True, fTime)
		EndIf
	EndFunction

	FormList Function GetNthStyle(Int aiParam)
		Return flStylesMaster.GetAt(aiParam) as FormList
	EndFunction

	FormList Function GetNthLength(Int aiParam)
		Return flCurrentStyle.GetAt(aiParam) as FormList
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
					ScheduleSwitch(False)
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
			PlayerRef.ChangeHeadPart(hpCurrentStage)
			SetPreviousSwitch()
			Return True
		Else
			Return False
		EndIf
	EndFunction

	Function SetPreviousSwitch()
		fPreviousSwitch = Utility.GetCurrentGameTime()
	EndFunction

	Bool Function SwitchToNextHeadPart()
		HeadPart hpCandidate = GetNextHeadPart(flCurrentLength)
		If(hpCandidate)
			Return SetHeadPart(hpCandidate)
		Else
			Return False
		EndIf
	EndFunction

	Int Function GetCurrentStage()
		Return flCurrentLength.Find(hpCurrentStage)
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

	HeadPart Function GetPreviousHeadPart(FormList aflParam = None)
		If(aflParam == None)
			aflParam = flCurrentLength
		EndIf
		Int iIndex = aflParam.Find(hpCurrentStage)
		If(iIndex > 0)
			iIndex -= 1
			Return aflParam.GetAt(iIndex) as HeadPart
		Else ;iIndex <= 0
			Return None
		EndIf
	EndFunction

	Function ToggleCutscene()
		bCutScene = !bCutScene
	EndFunction

	Function ToggleFollower()
		If(PlayerRef.HasSpell(kFollowerCloak))
			PlayerRef.RemoveSpell(kFollowerCloak)
			Int iCount = Self.GetNumAliases()
			Int i = 0
			While(i < iCount)
				ReferenceAlias kRefAlias = Self.GetNthAlias(i) as ReferenceAlias
				If(kRefAlias)
					Actor kRefActor = kRefAlias.GetActorReference()
					If(kRefActor)
						If(kRefActor != PlayerRef)
							(kRefAlias as _5OS_Script_FollowerAlias).Restore()
							kRefActor.RemoveSpell(kFollowerAbility)
						EndIf
					EndIf
				EndIf
				i += 1
			EndWhile
		Else
			PlayerRef.AddSpell(kFollowerCloak, False)
		EndIf
	EndFunction

	Function ToggleBrawlBug()
		bBrawlBugFix = !bBrawlBugFix
	EndFunction

;###################################################################################################################################################################################################################################
; 2D array that stores values of when one can jump between style length FormLists
; 2D array framework by Chesko (http://forums.bethsoft.com/topic/1470401-2d-array-framework/)

;The YNodes* arrays contain integers indicating when the length can be trimmed to based on the 0th length (full beard). Check if the indicated HeadPart 
;Trim Style function uses this 2D array to check which length sub-FormList to use

	;Parameters - Obsolete
	Int iXSize = 8
	Int iYSize = 70

	;Arrays
	Int[] YNodes0
	Int[] YNodes1
	Int[] YNodes2
	Int[] YNodes3
	Int[] YNodes4
	Int[] YNodes5
	Int[] YNodes6
	Int[] YNodes7
	Int[] YNodes8

	Function Create_2D()
	    ;-----------\
	    ;Description \
	    ;----------------------------------------------------------------
	    ;Creates the 2D array.
	    
		;Specify integer literal here, must match iYSize
	    YNodes0 = new Int[13] ;Full beard
	    YNodes1 = new Int[13] ;Chinstrap
	    YNodes2 = new Int[13] ;Goatee
	    YNodes3 = new Int[13] ;Goat patch
	    YNodes4 = new Int[13] ;Horseshoe
	    YNodes5 = new Int[13] ;Moustache
	    YNodes6 = new Int[13] ;Muttonchops
	    YNodes7 = new Int[13] ;Sideburns
	    YNodes8 = new Int[13] ;Van Dyke
	EndFunction

	Function SetValues_2D()
		Int i = 0
	    While(i < 13)
	    	YNodes0[i] = -1
	    	YNodes1[i] = -1
	    	YNodes2[i] = -1
	    	YNodes3[i] = -1
	    	YNodes4[i] = -1
	    	YNodes5[i] = -1
	    	YNodes6[i] = -1
	    	YNodes7[i] = -1
	    	YNodes8[i] = -1
	    	i += 1
	    EndWhile

		;Beard
			YNodes0[1] = 6 ;06
			YNodes0[2] = 7 ;41
			YNodes0[3] = 23 ;42
			YNodes0[4] = 58 ;43
		
		;Chinstrap
			YNodes1[1] = 4 ;07
			YNodes1[2] = 5 ;08
			YNodes1[3] = 7 ;09
		
		;Goatee
			;Still need to figure out the values below
			YNodes2[1] = 4 ;31
			YNodes2[2] = 5 ;32
			YNodes2[3] = 6 ;33
			YNodes2[4] = 8 ;34_098
			YNodes2[5] = 13 ;34_099
			YNodes2[6] = 18 ;34
			YNodes2[7] = 50 ;35
			YNodes2[8] = 68 ;36
			YNodes2[9] = 68 ;45
			YNodes2[10] = 68 ;44
		
		;Goat patch
			YNodes3[1] = 5 ;12
			YNodes3[2] = 10 ;11
			YNodes3[3] = 15 ;10
			YNodes3[4] = 20 ;37_080
			YNodes3[5] = 25 ;37_085
			YNodes3[6] = 30 ;37_090
			YNodes3[7] = 35 ;37_095
			YNodes3[8] = 40 ;37_100
			YNodes3[9] = 45 ;37_105
			YNodes3[10] = 68 ;37

		;Horseshoe
			YNodes4[1] = 3
			YNodes4[2] = 4
			YNodes4[3] = 5
			YNodes4[4] = 6
			YNodes4[5] = 6
			YNodes4[6] = 7
			YNodes4[7] = 8
			YNodes4[8] = 13
			YNodes4[9] = 18
			YNodes4[10] = 28
			YNodes4[11] = 39
			YNodes4[12] = 49
		
		;Moustache
			;Still need to figure out the values below
			YNodes5[1] = 7
			YNodes5[2] = 7
			YNodes5[3] = 7
			YNodes5[4] = 49

		;Muttonchops
			YNodes6[1] = 4
			YNodes6[2] = 5
			YNodes6[3] = 6
		
		;Sideburns
			YNodes7[1] = 4
			YNodes7[2] = 5
			YNodes7[3] = 6
			YNodes7[4] = 40

		;Van Dyke
			YNodes8[1] = 4 ;13
			YNodes8[2] = 5 ;14
			YNodes8[3] = 6 ;15

	EndFunction

	Int[] function GetArrayFromID(int iID)
	    ;-----------\
	    ;Description \
	    ;----------------------------------------------------------------
	    ;Maps an ID to an array.
	    ;These arrays MUST be listed manually by the user in the code
	    ;below in order for the rest of the framework to function!

	    if iID == 0
	        return YNodes0
	    elseif iID == 1
	        return YNodes1
	    elseif iID == 2
	        return YNodes2
	    elseif iID == 3
	        return YNodes3
	    elseif iID == 4
	        return YNodes4
	    elseif iID == 5
	        return YNodes5
	    elseif iID == 6
	        return YNodes6
	    elseif iID == 7
	        return YNodes7
	    elseif iID == 8
	    	return YNodes8
	    endIf
	EndFunction

	Int Function Read_2D(int iX, int iY)
	    ;-----------\
	    ;Description \
	    ;----------------------------------------------------------------
	    ;Returns the value at the given indicies.

	    return GetArrayFromID(iX)[iY]
	EndFunction

	Bool Function IsEmpty_2D(int iX, int iY)
	    ;-----------\
	    ;Description \
	    ;----------------------------------------------------------------
	    ;Checks whether or not the field at the given indicies is -1.

	    If GetArrayFromID(iX)[iY] == -1
	        return true
	    Else
	        return false
	    EndIf
	EndFunction

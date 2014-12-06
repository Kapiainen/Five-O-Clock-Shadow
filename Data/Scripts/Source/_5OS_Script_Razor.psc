Scriptname _5OS_Script_Razor extends ObjectReference  

Actor Property PlayerRef Auto
_5OS_Script_BeardGrowth Property BeardGrowth Auto
Message Property msgMainMenu Auto
Message Property msgStylesMenu Auto
Message Property msgUpdateMenu Auto
Message Property msgGameTimeFrequencyMenu Auto

Event OnEquipped(Actor akActor)
	If((akActor == PlayerRef) && (!PlayerRef.IsInCombat()) && (!PlayerRef.IsSwimming()))
		Game.DisablePlayerControls()
		Game.EnablePlayerControls()
		Int iChoice = 0
		While(iChoice != 7)
			iChoice = msgMainMenu.Show()
			If(iChoice == 0) ;Maintain (bGrowing)
				BeardGrowth.Maintain()
			ElseIf(iChoice == 1) ;Let grow (!bGrowing)
				BeardGrowth.LetGrow()
			ElseIf(iChoice == 2) ;Trim length
				BeardGrowth.TrimLength()
			ElseIf(iChoice == 3) ;Trim style (Stage > 0 aka iCurrentStyle = i, iCurrentLength = j, iCurrentStage > 0)
				BeardGrowth.TrimStyle()
			ElseIf(iChoice == 4) ;Clean shave - Sets iCurrentLength to 0 and iCurrentStage to 0
				BeardGrowth.CleanShave()
			ElseIf(iChoice == 5) ;Select style - Beard, Chinstrap, Goatee, Goat Patch, Horseshoe, Moustache, Muttonchops, Sideburns
				Int iStyles = msgStylesMenu.Show()
				If(iStyles < 9) ;Styles
					BeardGrowth.SetNthStyle(iStyles)
					BeardGrowth.SetNthLength(0)
					Int iIndex = BeardGrowth.GetCurrentStage()
					If(iIndex < 0)
						iIndex = 0
					EndIf
					BeardGrowth.SetNthStage(iIndex)
				ElseIf(iStyles == 9) ;Back
				EndIf
			ElseIf(iChoice == 6) ;Update and frequency
				Int iUpdate = 0
				While(iUpdate < 9)
					iUpdate = msgUpdateMenu.Show()
					If(iUpdate == 0) ;Game time
						Int iFrequency = 0
						While(iFrequency != 4)
							iFrequency = msgGameTimeFrequencyMenu.Show(BeardGrowth.fGameTimeFrequency)
							If(iFrequency == 0) ;-24
								BeardGrowth.ModFrequency(-24.0) ;fGameTimeFrequency -= 24.0
							ElseIf(iFrequency == 1) ;-12
								BeardGrowth.ModFrequency(-12.0)
							ElseIf(iFrequency == 2) ;-6
								BeardGrowth.ModFrequency(-6.0)
							ElseIf(iFrequency == 3) ;-1
								BeardGrowth.ModFrequency(-1.0)
							ElseIf(iFrequency == 4) ;Back
								
							ElseIf(iFrequency == 5) ;+1
								BeardGrowth.ModFrequency(1.0)
							ElseIf(iFrequency == 6) ;+6
								BeardGrowth.ModFrequency(6.0)
							ElseIf(iFrequency == 7) ;+12
								BeardGrowth.ModFrequency(12.0)
							ElseIf(iFrequency == 8) ;+24
								BeardGrowth.ModFrequency(24.0)
							EndIf
						EndWhile
					ElseIf(iUpdate == 1) ;Update Mode
						BeardGrowth.SleepOnly(False)
					ElseIf(iUpdate == 2) ;Sleep Mode
						BeardGrowth.SleepOnly()
					ElseIf(iUpdate == 3) ;Cutscene on
						BeardGrowth.ToggleCutscene()
					ElseIf(iUpdate == 4) ;Cutscene off
						BeardGrowth.ToggleCutscene()
					ElseIf(iUpdate == 5) ;Enable follower support
						BeardGrowth.ToggleFollower()
					ElseIf(iUpdate == 6) ;Disable follower support
						BeardGrowth.ToggleFollower()
					ElseIf(iUpdate == 7) ;Enable Brawl Bug fix
						BeardGrowth.ToggleBrawlBug()
					ElseIf(iUpdate == 8) ;Disable Brawl Bug fix
						BeardGrowth.ToggleBrawlBug()
					ElseIf(iUpdate == 9) ;Back
						
					EndIf
				EndWhile
			ElseIf(iChoice == 7) ;Exit
				
			EndIf
		EndWhile
		;BeardGrowth.
	EndIf
EndEvent

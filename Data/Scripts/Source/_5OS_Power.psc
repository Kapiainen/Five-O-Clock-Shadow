Scriptname _5OS_Power extends activemagiceffect  

_5OS_PlayerAlias Property System Auto
Message Property _5OS_MESSAGE_Main Auto
Message Property _5OS_MESSAGE_Styles1 Auto
;Message Property _5OS_MESSAGE_ Auto

Event OnEffectStart(Actor akTarger, Actor akCaster)
	Bool bFlag = False
	While(!bFlag)
		Int iChoice = _5OS_MESSAGE_Main.Show()
		If(iChoice == 0)
			System.Trim()
		ElseIf(iChoice == 1)
			System.CleanShave()
		ElseIf(iChoice == 2)
			System.UnregisterForUpdateGameTime()
		ElseIf(iChoice == 3)
			System.RegisterForSingleUpdateGameTime(System.ScheduleUpdate())
		ElseIf(iChoice == 4)
			iChoice = _5OS_MESSAGE_Styles1.Show()
			If(iChoice < 8)
				System.SetStyle(iChoice)
			Else
				;Back
			EndIf
		ElseIf(iChoice == 5)
			;Exit
			bFlag = True
		EndIf
	EndWhile
EndEvent

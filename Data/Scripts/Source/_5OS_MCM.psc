Scriptname _5OS_MCM extends SKI_ConfigBase

FormList Property flInvalidRaces Auto
Actor Property PlayerRef Auto
Spell Property kPower Auto
MiscObject Property kRazor Auto
_5OS_BeardGrowth Property System Auto

Float Property fGrowthRate = 24.0 Auto Hidden
Bool Property bUpdateOnWakeUp = False Auto Hidden
Bool Property bPower = True Auto Hidden

Bool bUnsupportedRace = False
Bool bAddPowerRazor = False

Event OnInit()
	Parent.OnInit()
EndEvent

Event OnPageReset(String Page)
	If(flInvalidRaces.Find(PlayerRef.GetRace()) >= 0)
		bUnsupportedRace = True
	Else
		bUnsupportedRace = False
	EndIf
	If(!bUnsupportedRace)
		AddSliderOptionST("stGrowthRate", "Rate of growth", fGrowthRate, "{0} hours/stage")
		AddToggleOptionST("stUpdateOnWakeUp", "Update when waking up", bUpdateOnWakeUp)
		If(bPower)
			AddTextOptionST("stPowerRazor", "Switch to", "Razor")
		Else
			AddTextOptionST("stPowerRazor", "Switch to", "Power")
		EndIf
	Else
		AddHeaderOption("Unsupported race")
	EndIf
EndEvent

Event OnConfigClose()
	If(!bUnsupportedRace)
		If(bAddPowerRazor)
			If(bPower)
				Int iCount = PlayerRef.GetItemCount(kRazor)
				If(iCount > 0)
					PlayerRef.RemoveItem(kRazor, iCount)
				EndIf
				If(!PlayerRef.HasSpell(kPower))
					PlayerRef.AddSpell(kPower)
				EndIf
			Else
				If(PlayerRef.HasSpell(kPower))
					PlayerRef.RemoveSpell(kPower)
				EndIf
				If(PlayerRef.GetItemCount(kRazor) == 0)
					PlayerRef.AddItem(kRazor)
				EndIf
			EndIf
			If((bUpdateOnWakeUp) && (System.GetState() == ""))
				System.GoToState("stSleepUpdate")
				System.RegisterForSleep()
			ElseIf((!bUpdateOnWakeUp) && (System.GetState() != ""))
				System.GoToState("")
				System.UnregisterForSleep()
				System.UnregisterForUpdateGameTime()
				System.OnUpdateGameTime()
			EndIf
			bAddPowerRazor = False
		EndIf
	EndIf
EndEvent

State stUpdateOnWakeUp
	Event OnSelectST()
		bUpdateOnWakeUp = !bUpdateOnWakeUp
		SetToggleOptionValueST(bUpdateOnWakeUp)
	EndEvent
	
	Event OnDefaultST()
		bUpdateOnWakeUp = True
		SetToggleOptionValueST(bUpdateOnWakeUp)
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("")
	EndEvent
EndState

State stGrowthRate
	Event OnSliderOpenST()
		SetSliderDialogStartValue(fGrowthRate)
		SetSliderDialogDefaultValue(24.0)
		SetSliderDialogRange(1.0, 168.0)
		SetSliderDialogInterval(1.0)
	EndEvent
	
	Event OnSliderAcceptST(Float afValue)
		fGrowthRate = afValue
		SetSliderOptionValueST(fGrowthRate, "{0} hours/stage")
		System.UnregisterForUpdateGameTime()
		System.RegisterForSingleUpdateGameTime(System.ScheduleUpdate())
	EndEvent
	
	Event OnDefaultST()
		fGrowthRate = 24.0
		SetSliderOptionValueST(fGrowthRate, "{0} hours/stage")
		System.UnregisterForUpdateGameTime()
		System.RegisterForSingleUpdateGameTime(System.ScheduleUpdate())
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("")
	EndEvent
EndState

State stPowerRazor
	Event OnSelectST()
		bPower = !bPower
		bAddPowerRazor = True
		ForcePageReset()
	EndEvent
	
	Event OnDefaultST()
		bPower = True
		bAddPowerRazor = True
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("")
	EndEvent
EndState

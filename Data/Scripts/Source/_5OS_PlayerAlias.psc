Scriptname _5OS_PlayerAlias extends ReferenceAlias

_5OS_BeardGrowth Property System Auto
FormList Property flVariations Auto
FormList Property flValidBeards Auto

Event OnInit()
	DetectMods()
EndEvent

Event OnPlayerLoadGame()
	DetectMods()
EndEvent

Function DetectMods()
	If(Game.GetModByName("Beards.esp") != 255)
		If(!System.bModBeards)
			FormList flVariation = flVariations.GetAt(2) as FormList
			System.bModBeards = True
			flVariation.AddForm(Game.GetFormFromFile(0x010012C4, "Beards.esp") as HeadPart)
			flValidBeards.AddForm(Game.GetFormFromFile(0x010012C4, "Beards.esp") as HeadPart)
			
			flVariation.AddForm(Game.GetFormFromFile(0x01001829, "Beards.esp") as HeadPart)
			flValidBeards.AddForm(Game.GetFormFromFile(0x01001829, "Beards.esp") as HeadPart)
			
			flVariation.AddForm(Game.GetFormFromFile(0x0100182A, "Beards.esp") as HeadPart)
			flValidBeards.AddForm(Game.GetFormFromFile(0x0100182A, "Beards.esp") as HeadPart)
			
			flVariation.AddForm(Game.GetFormFromFile(0x01001D91, "Beards.esp") as HeadPart)
			flValidBeards.AddForm(Game.GetFormFromFile(0x01001D91, "Beards.esp") as HeadPart)
			
			flVariation.AddForm(Game.GetFormFromFile(0x0100182C, "Beards.esp") as HeadPart)
			flValidBeards.AddForm(Game.GetFormFromFile(0x0100182C, "Beards.esp") as HeadPart)
			
			flVariation.AddForm(Game.GetFormFromFile(0x01001D92, "Beards.esp") as HeadPart)
			flValidBeards.AddForm(Game.GetFormFromFile(0x01001D92, "Beards.esp") as HeadPart)
		EndIf
	Else
		System.bModBeards = False
	EndIf
EndFunction

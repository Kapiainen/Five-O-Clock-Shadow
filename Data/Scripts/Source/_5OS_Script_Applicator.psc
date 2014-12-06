Scriptname _5OS_Script_Applicator extends activemagiceffect  

Spell Property kAbility Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.AddSpell(kAbility, False)
EndEvent
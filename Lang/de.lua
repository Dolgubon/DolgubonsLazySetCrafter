-- Thanks to @xpleader and @PaigeEvenstar for the initial translations!

DolgubonSetCrafter = DolgubonSetCrafter or {}

DolgubonSetCrafter.lang = "de"

DolgubonSetCrafter.localizedStrings = {}

DolgubonSetCrafter.localizedStrings.UIStrings = {}
DolgubonSetCrafter.localizedStrings.UIStrings.patternHeader       = "Wähle deine Gegenstände aus"
DolgubonSetCrafter.localizedStrings.UIStrings.comboboxHeader      = "Attribute" -- same
DolgubonSetCrafter.localizedStrings.UIStrings.comboboxDefault     = "Wähle <<1>>" 
DolgubonSetCrafter.localizedStrings.UIStrings.selectPrompt        = "|cFF0000Bitte <<1>> auswählen!|r"
DolgubonSetCrafter.localizedStrings.UIStrings.style               = "Stil"
DolgubonSetCrafter.localizedStrings.UIStrings.level               = GetString(SI_ITEM_FORMAT_STR_LEVEL)
DolgubonSetCrafter.localizedStrings.UIStrings.CP                  = "CP"
DolgubonSetCrafter.localizedStrings.UIStrings.armourTrait         = "|t100%:100%:EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds|tEigenschaft"
DolgubonSetCrafter.localizedStrings.UIStrings.weaponTrait         = "|t100%:100%:DolgubonsLazySetCrafter/images/patterns/greatsword_up.dds|tEigenschaft"
DolgubonSetCrafter.localizedStrings.UIStrings.quality             = "Qualität"
DolgubonSetCrafter.localizedStrings.UIStrings.gearSet             = "Set"
DolgubonSetCrafter.localizedStrings.UIStrings.addToQueue          = "|c26CD00Auswahl → Warteschlange|r"
DolgubonSetCrafter.localizedStrings.UIStrings.queueHeader         = "Warteschlange der herzustellenden Gegenstände"
DolgubonSetCrafter.localizedStrings.UIStrings.clearQueue          = "|cFF0000Lösche Warteschlange|r"
DolgubonSetCrafter.localizedStrings.UIStrings.resetToDefault      = "|cFFD800Auswahl zurücksetzen|r"
DolgubonSetCrafter.localizedStrings.UIStrings.notEnoughKnowledge  = "Dein Wissen reicht für diese Eigenschaft nicht aus"
DolgubonSetCrafter.localizedStrings.UIStrings.notEnoughMats       = "You do not have enough materials to make this attribute"
DolgubonSetCrafter.localizedStrings.UIStrings.notEnoughSpecificMat= "You do not have enough of this material to craft all items"
DolgubonSetCrafter.localizedStrings.UIStrings.invalidLevel        = "Invalid Level"

DolgubonSetCrafter.localizedStrings.SettingStrings = {}

DolgubonSetCrafter.localizedStrings.SettingsStrings.nowEditing                   = "You are changing %s settings"
DolgubonSetCrafter.localizedStrings.SettingsStrings.accountWide                  = "Account Wide"
DolgubonSetCrafter.localizedStrings.SettingsStrings.characterSpecific            = "Character Specific"

DolgubonSetCrafter.localizedStrings.SettingStrings.showAtStation 				= "Bei Handwerkstation anzeigen"
DolgubonSetCrafter.localizedStrings.SettingStrings.showAtStationTooltip			= "Zeigt das Set Crafter Fenster beim Öffnen einer Handwerkstation automatisch an"
DolgubonSetCrafter.localizedStrings.SettingStrings.saveLastChoice				= "Save Choices"
DolgubonSetCrafter.localizedStrings.SettingStrings.saveLastChoiceTooltip		= "Save the last selected choices"
DolgubonSetCrafter.localizedStrings.SettingsStrings.closeOnExit                  = "Close on Station Exit"
DolgubonSetCrafter.localizedStrings.SettingsStrings.closeOnExitTooltip           = "Close the Set Crafter UI when exiting a crafting station"
DolgubonSetCrafter.localizedStrings.SettingsStrings.useCharacterSettings         = "Use character settings" 
DolgubonSetCrafter.localizedStrings.SettingsStrings.useCharacterSettingsTooltip  = "Use character specific settings on this character only"

DolgubonSetCrafter.localizedStrings.weaponNames = 
{
    "Axt", "Keule", "Schwert", "Streitaxt", "Streitkolben", "Bidenhänder", "Dolch", "Bogen", "Flammenstab", "Froststab", "Blitzstab", "Heilungsstab", "Schild"
}
DolgubonSetCrafter.localizedStrings.pieceNames = 
{
    "Torso","Füße","Hände","Kopf","Beine","Schultern","Taille","Hemd"
}
DolgubonSetCrafter.localizedStrings.armourTypes = 
{
    "Schwere", "Mittlere", "Leichte"
}


DolgubonSetCrafter.localizedStrings.optionStrings = {}
ZO_CreateStringId("SI_BINDING_NAME_SET_CRAFTER_OPEN", "Öffne/Schließe Set Crafter Fenster")
DolgubonSetCrafterWindowAdd:SetDimensions(230,28)
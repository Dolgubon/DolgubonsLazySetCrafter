-- Thanks to @xpleader and @PaigeEvenstar for the initial translations!

DolgubonSetCrafter = DolgubonSetCrafter or {}

DolgubonSetCrafter.lang = "de"

DolgubonSetCrafter.localizedStrings = DolgubonSetCrafter.localizedStrings or {}

DolgubonSetCrafter.localizedStrings.UIStrings = DolgubonSetCrafter.localizedStrings.UIStrings or {}
DolgubonSetCrafter.localizedStrings.UIStrings.patternHeader       = "Wähle deine Gegenstände aus"
DolgubonSetCrafter.localizedStrings.UIStrings.comboboxHeader      = "Attribute" -- same
DolgubonSetCrafter.localizedStrings.UIStrings.comboboxDefault     = "Wähle <<1>>" 
DolgubonSetCrafter.localizedStrings.UIStrings.selectPrompt        = "|cFF0000Bitte <<1>> auswählen!|r"
DolgubonSetCrafter.localizedStrings.UIStrings.style               = "Stil"
DolgubonSetCrafter.localizedStrings.UIStrings.level               = GetString(SI_ITEM_FORMAT_STR_LEVEL)
DolgubonSetCrafter.localizedStrings.UIStrings.CP                  = "CP"
DolgubonSetCrafter.localizedStrings.UIStrings.armourTrait         = "|t100%:100%:EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds|tEigenschaft"
DolgubonSetCrafter.localizedStrings.UIStrings.weaponTrait         = "|t100%:100%:DolgubonsLazySetCrafter/images/patterns/greatsword_up.dds|tEigenschaft"
DolgubonSetCrafter.localizedStrings.UIStrings.jewelryTrait			= "Schmuck Eigenschaft"
DolgubonSetCrafter.localizedStrings.UIStrings.quality             = "Qualität"
DolgubonSetCrafter.localizedStrings.UIStrings.gearSet             = "Set"
DolgubonSetCrafter.localizedStrings.UIStrings.addToQueue          = "|c26CD00Auswahl → Warteschlange|r"
DolgubonSetCrafter.localizedStrings.UIStrings.queueHeader         = "Warteschlange der herzustellenden Gegenstände"
DolgubonSetCrafter.localizedStrings.UIStrings.clearQueue          = "|cFF0000Lösche Warteschlange|r"
DolgubonSetCrafter.localizedStrings.UIStrings.resetToDefault      = "|cFFD800Auswahl zurücksetzen|r"
DolgubonSetCrafter.localizedStrings.UIStrings.notEnoughKnowledge  = "Dein Wissen reicht für diese Eigenschaft nicht aus"
DolgubonSetCrafter.localizedStrings.UIStrings.notEnoughMats       = "Du besitzt nicht genug Materialien, um dieses Attribut herzustellen"
DolgubonSetCrafter.localizedStrings.UIStrings.notEnoughSpecificMat= "Du besitzt nicht genug von diesem Material, um alle Gegenstände herzustellen"
DolgubonSetCrafter.localizedStrings.UIStrings.invalidLevel        = "Ungültiges Level"
DolgubonSetCrafter.localizedStrings.UIStrings.multiplier 			= "Anzahl"
DolgubonSetCrafter.localizedStrings.UIStrings.autoCraft 			= "Automatische Herstellung"
DolgubonSetCrafter.localizedStrings.UIStrings.craftStart 			= "Herstellung Beginnen"
DolgubonSetCrafter.localizedStrings.UIStrings.mimicStones			= "Mimenstein benutzen"
DolgubonSetCrafter.localizedStrings.UIStrings.materialScrollTitle 	="Materialvoraussetzungen"
DolgubonSetCrafter.localizedStrings.UIStrings.mailRequirements 		="Voraussetzungen per Mail"
DolgubonSetCrafter.localizedStrings.UIStrings.chatRequirements 		="In Chat einfügen"
DolgubonSetCrafter.localizedStrings.UIStrings.defaultUserId 		="@UserId eingeben"
DolgubonSetCrafter.localizedStrings.UIStrings.usesMimicStone		= "Ihr benötigt einen Kronen-Mimenstein um diesen Gegenstand herstellen zu können"

DolgubonSetCrafter.localizedStrings.SettingsStrings = DolgubonSetCrafter.localizedStrings.SettingsStrings or {}

DolgubonSetCrafter.localizedStrings.SettingsStrings.nowEditing                   = "Du änderst %s Einstellungen"
DolgubonSetCrafter.localizedStrings.SettingsStrings.accountWide                  = "Gesamtes Konto"
DolgubonSetCrafter.localizedStrings.SettingsStrings.characterSpecific            = "Charakter spezifisch"

DolgubonSetCrafter.localizedStrings.SettingsStrings.showAtStation 				= "Bei Handwerkstation anzeigen"

DolgubonSetCrafter.localizedStrings.SettingsStrings.showAtStationTooltip			= "Zeigt das Set Crafter Fenster beim Öffnen einer Handwerkstation automatisch an"
DolgubonSetCrafter.localizedStrings.SettingsStrings.saveLastChoice				= "Auswahl sichern"
DolgubonSetCrafter.localizedStrings.SettingsStrings.saveLastChoiceTooltip		= "Sichert die zuletzt gewählte Auswahl"
DolgubonSetCrafter.localizedStrings.SettingsStrings.closeOnExit                  = "Schließen beim Verlassen"
DolgubonSetCrafter.localizedStrings.SettingsStrings.closeOnExitTooltip           = "Schließt die Set Crafter Benutzeroberfläche, wenn eine Handwerksstation verlassen wird"
DolgubonSetCrafter.localizedStrings.SettingsStrings.useCharacterSettings         = "Nutze Charakter Einstellungen"
DolgubonSetCrafter.localizedStrings.SettingsStrings.useCharacterSettingsTooltip  = "Speichert für diesen Charakter die Einstellungen spezifisch ab, nicht für das gesamte Konto."
DolgubonSetCrafter.localizedStrings.SettingsStrings.showToggleButton              = "Umschaltknopf anzeigen"
DolgubonSetCrafter.localizedStrings.SettingsStrings.showToggleButtonTooltip       = "Zeigt den Knopf zum Umschalten der Benutzeroberfläche des Addons immer an"
DolgubonSetCrafter.localizedMatScrollWidth                                          = 300


DolgubonSetCrafter.localizedStrings.weaponNames = 
{
    "Axt", "Keule", "Schwert", "Streitaxt", "Streitkolben", "Bidenhänder", "Dolch", "Bogen", "Flammenstab", "Froststab", "Blitzstab", "Heilungsstab", "Schild"
}
DolgubonSetCrafter.localizedStrings.jewelryNames = 
{
    "Ring","Ring" , "Halskette",
}
DolgubonSetCrafter.localizedStrings.pieceNames = 
{
    "Torso","Füße","Hände","Kopf","Beine","Schultern","Taille","Hemd"
}
DolgubonSetCrafter.localizedStrings.armourTypes = 
{
    "Schwere", "Mittlere", "Leichte"
}


ZO_CreateStringId("SI_BINDING_NAME_SET_CRAFTER_OPEN", "Öffne/Schließe Set Crafter Fenster")
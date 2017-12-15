local panel =  
{
     type = "panel",
     name = "Dolgubon's Lazy Set Crafter",
     registerForRefresh = true,
     displayName = "|c8080FF Dolgubon's Lazy Set Crafter|r",
     author = "@Dolgubon"
}

local options =
{
	{
		type = "checkbox",
		name = DolgubonSetCrafter.localizedStrings.SettingStrings.showAtStation,
		tooltip =DolgubonSetCrafter.localizedStrings.SettingStrings.showAtStationTooltip,
		getFunc = function() return DolgubonSetCrafter.charSavedVars.OpenAtCraftStation end,
		setFunc = function(value) 
			DolgubonSetCrafter.charSavedVars.OpenAtCraftStation = value
		end,
	},
	{
		type = "checkbox",
		name = DolgubonSetCrafter.localizedStrings.SettingStrings.saveLastChoice,
		tooltip =DolgubonSetCrafter.localizedStrings.SettingStrings.saveLastChoiceTooltip,
		getFunc = function() return DolgubonSetCrafter.savedVars.saveLastChoice end,
		setFunc = function(value) 
			DolgubonSetCrafter.savedVars.saveLastChoice = value
		end,
	},
}

function DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu()

	local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsSetCrafter", panel)
	
	LAM:RegisterOptionControls("DolgubonsSetCrafter", options)
end
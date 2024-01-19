local panel =  
{
     type = "panel",
     name = "Lazy Set Crafter",
     registerForRefresh = true,
     displayName = "|c8080FF Dolgubon's Lazy Set Crafter|r",
     author = "@Dolgubon"
}
local function shallowCopy (source, destination)
	for k, v in pairs(source) do
		destination[k] = v
	end
end

local SettingsStrings = DolgubonSetCrafter.localizedStrings.SettingsStrings

local options =
{
	{
		type = "header",
		name = function() 
			local profile = SettingsStrings.accountWide
			if DolgubonSetCrafter.charSavedVars.useCharacterSettings then
				profile = SettingsStrings.characterSpecific
			end
			return  string.format(SettingsStrings.nowEditing, profile)  
		end, -- or string id or function returning a string
	},
	{
		type = "checkbox",
		name = SettingsStrings.useCharacterSettings,
		tooltip = SettingsStrings.useCharacterSettingsTooltip,
		getFunc = function() return DolgubonSetCrafter.charSavedVars.useCharacterSettings end,
		setFunc = function(value) 
			DolgubonSetCrafter.charSavedVars.useCharacterSettings = value
		end,
	},
	{
		type = "divider",
		height = 15,
		alpha = 0.5,
		width = "full"
	},
	{
		type = "checkbox",
		name = SettingsStrings.showAtStation,
		tooltip =SettingsStrings.showAtStationTooltip,
		getFunc = function() return DolgubonSetCrafter:GetSettings().OpenAtCraftStation end,
		setFunc = function(value) 
			DolgubonSetCrafter:GetSettings().OpenAtCraftStation = value
		end,
	},
	{
		type = "checkbox",
		name = SettingsStrings.closeOnExit,
		tooltip =SettingsStrings.closeOnExitTooltip,
		getFunc = function() return DolgubonSetCrafter:GetSettings().closeOnExit end,
		setFunc = function(value) 
			DolgubonSetCrafter:GetSettings().closeOnExit = value
		end,
	},
	{
		type = "checkbox",
		name = SettingsStrings.showToggleButton,
		tooltip =SettingsStrings.showToggleButtonTooltip,
		getFunc = function() return DolgubonSetCrafter:GetSettings().showToggle end,
		setFunc = function(value) 
			DolgubonSetCrafter:GetSettings().showToggle = value
			DolgubonSetCrafterToggle:SetHidden(not value )
		end,
	},
	
	{
		type = "checkbox",
		name = SettingsStrings.saveLastChoice,
		tooltip =SettingsStrings.saveLastChoiceTooltip,
		getFunc = function() return DolgubonSetCrafter.savedvars.saveLastChoice end,
		setFunc = function(value) 
			DolgubonSetCrafter.savedvars.saveLastChoice = value
		end,
	},

	-- {
	-- 	type = "checkbox",
	-- 	name = SettingsStrings.showFavourites,
	-- 	tooltip =SettingsStrings.showFavouritesTooltip,
	-- 	getFunc = function() return DolgubonSetCrafter:GetSettings().showFavourites end,
	-- 	setFunc = function(value) 
	-- 		DolgubonSetCrafter:GetSettings().showFavourites = value
	-- 		DolgubonSetCrafterWindowFavourites:SetHidden(not value)
	-- 	end,
	-- },
	
	
}

function DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu()

	local LAM = LibAddonMenu2 or LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsSetCrafter", panel)
	
	LAM:RegisterOptionControls("DolgubonsSetCrafter", options)
end
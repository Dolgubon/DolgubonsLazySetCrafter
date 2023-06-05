-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
------------------------------------
-- Namespace and variable initialization
DolgubonSetCrafter = DolgubonSetCrafter or {}
DolgubonSetCrafter.initializeFunctions = DolgubonSetCrafter.initializeFunctions or {}
--77 81 91

DolgubonSetCrafter.defaultCharacter = 
{
	["OpenAtCraftStation"] = true,
	["autocraft"] = true,
	["closeOnExit"] = true,
	["useCharacterSettings"] = false,
	["showToggle"] = false,
}
DolgubonSetCrafter.default = {
	["queue"] = {},
	["xPos"] = 0,
	["yPos"] = 0,
	["counter"] = 0,
	[6697110] = false,
	["saveLastChoice"] = true,
	["accountWideProfile"] = DolgubonSetCrafter.defaultCharacter,
	["notifyWiped"] = true,
	['autoCraft'] = true,
	['toggleXPos'] = 50,
	['toggleYPost'] = 50,
	['width'] = DolgubonSetCrafter.defaultWidth,
	['height'] = DolgubonSetCrafter.defaultHeight,
	['faves'] = {},
	['showFavourites'] = true,
	['currentPriceChoice'] = 1,
	['notifyNewFeatures'] = 
	{
		['homeStation'] = false,
		['priceSwitch'] = false,
	}
}
local newFeatureInfo =
{
	['homeStation'] = "· Dolgubon's Lazy Set Crafter now has integration with Home Station Marker!\n You can check it out on ESOUI or Minion",
	['priceSwitch'] = "· You can now switch between different pricing sources in Dolgubon's Lazy\n Set Crafter by clicking the question mark on the materials list",
}


DolgubonSetCrafter.version = 5
DolgubonSetCrafter.name = "DolgubonsLazySetCrafter"


local out = DolgubonSetCrafter.out


--Takes in a number, determines if it's a simple integer with no exponents
local function isInteger(text)
	return not string.find(text,"d") and string.find(text,"e") and string.find(text,".",1,true) 
end

local previousText = ""
function DolgubonSetCrafter.onTextChanged()
	local text = DolgubonSetCrafterWindowInputBox:GetText()
	if tonumber(text) and not isInteger(text) then --if the string can be converted to a number then
		--updatePreview() --update the preview to the new level
		previousText = text
	elseif text=="" then --Do nothing if it is empty
		previousText = text
	else --else remove the most recently added item
		
		DolgubonSetCrafterWindowInputBox:SetText(previousText)
	end
end

function DolgubonSetCrafter.onEnter()
	--d(DolgubonsGuildBlacklistWindowInputBox:GetText())
end

function DolgubonSetCrafter:GetSettings()
	if self.charSavedVars.useCharacterSettings then
		return self.charSavedVars
	else
		return self.savedvars.accountWideProfile
	end
end


function DolgubonSetCrafter:Initialize()
	--[[LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsWritCrafter", DolgubonSetCrafter.settings["panel"])
	DolgubonSetCrafter.settings["options"] = DolgubonSetCrafter.langOptions()
	LAM:RegisterOptionControls("DolgubonsWritCrafter", DolgubonSetCrafter.settings["options"])]]
	

	DolgubonSetCrafter.savedvars = ZO_SavedVars:NewAccountWide("dolgubonslazysetcraftersavedvars", 
		DolgubonSetCrafter.version, nil, DolgubonSetCrafter.default)

	DolgubonSetCrafter.charSavedVars = ZO_SavedVars:NewCharacterIdSettings("dolgubonslazysetcraftersavedvars",
		DolgubonSetCrafter.version, nil, DolgubonSetCrafter.savedvars.accountWideProfile) 
		-- Use the account Wide profile as the default

	--[[EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_PLAYER_ACTIVATED, function() 
		if DolgubonSetCrafter.savedvars.notifyWiped then 
			d("Dolgubon's Lazy Set Crafter settings have been wiped with this update")
			DolgubonSetCrafter.savedvars.notifyWiped = false
		end end)]]

	LLC, version = LibLazyCrafting, LibLazyCrafting.version
	if version <2.96 then
		out("Your version of LibLazyCrafting is incompatible with this version of Dolgubon's Lazy Set Crafter. Please update the library.")
		out = function() end
	end

	--if pcall(DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu) then else d("Dolgubon's Lazy Set Crafter: USettings not loaded") end
	DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu()
	--if pcall(DolgubonSetCrafter.initializeFunctions.initializeCrafting) then else d("Dolgubon's Lazy Set Crafter: UCrafting not loaded") end
	DolgubonSetCrafter.initializeFunctions.initializeCrafting()
	--if pcall(DolgubonSetCrafter.initializeFunctions.setupUI) then else d("Dolgubon's Lazy Set Crafter: UI not loaded") end
	DolgubonSetCrafter.initializeFunctions.setupUI()
	
	--DolgubonSetCrafter.initializeFeedbackWindow()
	local LibFeedback = LibFeedback
	local button, window = LibFeedback:initializeFeedbackWindow(DolgubonSetCrafter, "Dolgubon's Lazy Set Crafter",DolgubonSetCrafterWindow, "@Dolgubon", 
		{TOPLEFT , DolgubonSetCrafterWindow , TOPLEFT , 10, 10}, 
		{0,5000,50000, "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7CZ3LW6E66NAU"}, 
		"If you found a bug, have a request or a suggestion, or wish to donate, you can send me a mail here.")
	window:SetHidden(true)

	local currentAPIVersionOfAddon = 101038

	if GetAPIVersion() > currentAPIVersionOfAddon and GetWorldName()~="PTS" then 
		d("Update your addons!") 
		out("Your version of Dolgubon's Lazy Set Crafter is out of date. Please update your addons.")
		out = function() end
	end

	if GetAPIVersion() > currentAPIVersionOfAddon and GetDisplayName()=="@Dolgubon" and GetWorldName()=="PTS"  then 
		for i = 1 , 20 do 
			d("Set a reminder to change the API version of addon in Set Crafter Initialization function when the game update comes out.") 
		end
		out("Set a reminder to change the API version of addon in Set Crafter Initialization function when the game update comes out.") 
			out = function() end
	end
	if DolgubonSetCrafter.savedvars.debug then
		DolgubonSetCrafterWindow:SetHidden(false)
		DolgubonSetCrafterWindowRightInputBox:SetText("@Dolgubonn")
		DolgubonSetCrafter.updateList()
	end
	DolgubonSetCrafter.initializeMailButtons()
	DolgubonSetCrafterWindowFavourites:SetHidden(not DolgubonSetCrafter:GetSettings().showFavourites)

	local updateString = ""
	local showUpdate = false
	for k, v in pairs(DolgubonSetCrafter.savedvars.notifyNewFeatures) do
		if not v then
			updateString = updateString .. "\n" .. newFeatureInfo[k]
			DolgubonSetCrafter.savedvars.notifyNewFeatures[k] = true
			showUpdate = true
		end
	end
	if showUpdate then
		DolgubonSetCrafterUpdateInfo:SetHidden(false)
		DolgubonSetCrafterUpdateInfoUpdateInfo:SetText(updateString)
	end
end

local function closeWindow (optionalOverride)
	if optionalOverride==nil then optionalOverride = not DolgubonSetCrafterWindow:IsHidden() end
	DolgubonSetCrafter.updateList()
	DolgubonSetCrafterWindow:SetHidden(optionalOverride) 
	CraftingQueueScroll:SetHidden(optionalOverride)

end

DolgubonSetCrafter.close = closeWindow

local function slashcommand (input)closeWindow () end



function DolgubonSetCrafter.OnAddOnLoaded(event, addonName)
	--closeWindow()
	if addonName == DolgubonSetCrafter.name then
		DolgubonSetCrafter:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_CRAFTING_STATION_INTERACT, 
	function(event, station) 
		if station <=3 or station >5 then
			if not DolgubonSetCrafter:GetAutocraft() then
				DolgubonSetCrafter.toggleCraftButton(true)
			end
			if DolgubonSetCrafter:GetSettings().OpenAtCraftStation then 
				closeWindow(false) 
			else
				DolgubonSetCrafterToggle:SetHidden(false )
			end
		end 
	end)

EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_END_CRAFTING_STATION_INTERACT, 
	function(event, station) 
		if (station <=3 or station >5) then
			DolgubonSetCrafter.toggleCraftButton(false)
			if DolgubonSetCrafter:GetSettings().closeOnExit then closeWindow(true) 
			end 
			if not DolgubonSetCrafter:GetSettings().showToggle then
				DolgubonSetCrafterToggle:SetHidden(true)
			end
		end
	end)
EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_ADD_ON_LOADED, DolgubonSetCrafter.OnAddOnLoaded)

--EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_CRAFT_COMPLETED , d)


SLASH_COMMANDS["/dlsc"] = slashcommand
SLASH_COMMANDS["/dsc"] = slashcommand
SLASH_COMMANDS["/setcrafter"] = slashcommand
SLASH_COMMANDS["/setcrafterdebugmode"] =
function() 
	DolgubonSetCrafter.savedvars.debug = not DolgubonSetCrafter.savedvars.debug 
	d("Debug mode toggled "..tostring(DolgubonSetCrafter.savedvars.debug)) closeWindow(not DolgubonSetCrafter.savedvars.debug )
	DolgubonSetCrafter.debugFunctions()

end

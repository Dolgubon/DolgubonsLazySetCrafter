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

DolgubonSetCrafter.default = {
	["queue"] = {},
	["xPos"] = 0,
	["yPos"] = 0,
	["counter"] = 0,
}
DolgubonSetCrafter.defaultCharacter = 
{
	["OpenAtCraftStation"] = true,
	["autocraft"] = true,
}


DolgubonSetCrafter.version = 3
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




function DolgubonSetCrafter:Initialize()
	--[[LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsWritCrafter", DolgubonSetCrafter.settings["panel"])
	DolgubonSetCrafter.settings["options"] = DolgubonSetCrafter.langOptions()
	LAM:RegisterOptionControls("DolgubonsWritCrafter", DolgubonSetCrafter.settings["options"])]]
	

	DolgubonSetCrafter.savedVars = ZO_SavedVars:NewAccountWide("dolgubonslazysetcrafter", DolgubonSetCrafter.version, nil, DolgubonSetCrafter.default)
	DolgubonSetCrafter.charSavedVars = ZO_SavedVars:NewCharacterIdSettings("dolgubonslazysetcrafter",DolgubonSetCrafter.version, nil, DolgubonSetCrafter.defaultCharacter)
	
	LLC = LibStub:GetLibrary("LibLazyCrafting")
	if DolgubonSetCrafter.savedVars.debug then
		DolgubonSetCrafterWindow:SetHidden(false)
	end
	DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu()
	DolgubonSetCrafter.initializeFunctions.initializeCrafting()
	DolgubonSetCrafter.initializeFunctions.setupUI()

	DolgubonSetCrafter.initializeFeedbackWindow()
end

local function closeWindow (optionalOverride)
	if optionalOverride==nil then optionalOverride = not DolgubonSetCrafterWindow:IsHidden() end
	DolgubonSetCrafterWindow:SetHidden(optionalOverride) 
	CraftingQueueScroll:SetHidden(optionalOverride)
	DolgubonSetCrafterConfirm:SetHidden(true)
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
	function(event, station) if station <3 or station >5 then if DolgubonSetCrafter.charSavedVars.OpenAtCraftStation then closeWindow(false) end end end)

EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_END_CRAFTING_STATION_INTERACT, 
	function(event, station) if station <3 or station >5 then closeWindow(true) end end)
EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_ADD_ON_LOADED, DolgubonSetCrafter.OnAddOnLoaded)
--EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_CRAFT_COMPLETED , d)


SLASH_COMMANDS["/dlsc"] = slashcommand
SLASH_COMMANDS["/dsc"] = slashcommand
SLASH_COMMANDS["/setcrafter"] = slashcommand
SLASH_COMMANDS["/setcrafterdebugmode"] =
function() 
	DolgubonSetCrafter.savedVars.debug = not DolgubonSetCrafter.savedVars.debug 
	d("Debug mode toggled "..tostring(DolgubonSetCrafter.savedVars.debug)) closeWindow(DolgubonSetCrafter.savedVars.debug )
	DolgubonSetCrafter.debugFunctions()

end

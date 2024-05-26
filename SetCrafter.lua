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
	},
	["initialFurniture"] = false,
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

local craftingHouses = 
{
	["NA Megaserver"] = 
	{
		{displayName = "@xGAMxHQ", houseId = 71, greeting = "Welcome to Moon's Edge's guild house!", subheading = "Stations straight ahead", 
			chatMessage = "Like their guild house and want to join? Check them out here: |H1:guild:391101|hMoon's Edge|h"},
		{displayName = "@Amrayia", houseId = 71, greeting = "Welcome to Auction House Central's guild house!", subheading = "Stations straight ahead", 
			chatMessage = "Like their house? Join AHC in Alinor - where friendly traders thrive. Check it out here: |H1:guild:370167|hAuction House Central|h"},
		{displayName = "@Kelinmiriel", houseId = 40, greeting = "Welcome to Kelinmiriel's house!", subheading = "Stations to your left", chatMessage = ""},
		{displayName = "@AuctionsBMW", houseId = 62, greeting = "Welcome to Black Market Wares' guild house!", subheading = "Stations to your left", 
			chatMessage ="Like their guild house and want to join? Check them out here: |H1:guild:1427|hBlack Market Wares|h"},
	},
	["EU Megaserver"] = 
	{
		{displayName = "@JN_Slevin", houseId = 56, greeting = "Welcome to JNSlevin's house!", subheading = "Stations to the left", 
			chatMessage = "Welcome to the Independent Trading Team [ITT]'s guild house! if you find yourself in need of a "..
		"trading guild please join discord.gg/itt or contact @JN_Slevin, @LouAnja or @RichestGuyinESO. From Mournhold to Alinor we have a space for every every type of trader you might be!"},
		{displayName = "@Ek1", houseId = 66, greeting = "Welcome to Ek1's house!", subheading = "Stations right here!", chatMessage = ""},
	}
}


---Join AHC in Alinor - where traders thrive in a friendly community. Check it out here: |H1:guild:370167|hAuction House Central|h
-- Like their guild house? Join AHC in Alinor here: |H1:guild:370167|hAuction House Central|h
-- Like their house? Join AHC in Alinor - where friendly traders thrive. Check it out here: |H1:guild:370167|hAuction House Central|h
--GetCurrentHouseOwner()
-- GetCurrentZoneHouseId()
local houseToUse
local function displayGreeting(greeting, subHeading)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    messageParams:SetText(greeting, subHeading)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

local function welcomePlayerToHouse()
	if houseToUse and GetCurrentHouseOwner() == houseToUse.displayName and GetCurrentZoneHouseId()==houseToUse.houseId then
		displayGreeting(houseToUse.greeting, houseToUse.subheading)
		if houseToUse.chatMessage and houseToUse.chatMessage~="" then
			d(houseToUse.chatMessage)
		end
		houseToUse = nil
		EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name.."_houseWelcome", EVENT_PLAYER_ACTIVATED )
	end
end

function DolgubonSetCrafter.portToCraftingHouse()
	if GetWorldName()=="PTS" then
		d("No houses on PTS, since it changes where the copy comes from")
		return
	end
	houseToUse = craftingHouses[GetWorldName()][math.random(1, #craftingHouses[GetWorldName()] ) ]
	JumpToSpecificHouse(houseToUse.displayName, houseToUse.houseId)
	EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name.."_houseWelcome", EVENT_PLAYER_ACTIVATED , welcomePlayerToHouse)
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
	DolgubonSetCrafter.initializeFunctions.InitializeFurnitureUI()
	
	--DolgubonSetCrafter.initializeFeedbackWindow()
	local buttonInfo = {0,25000,100000, "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7CZ3LW6E66NAU"}
	if GetWorldName() == "NA Megaserver" then
		buttonInfo[#buttonInfo+1] = { function()JumpToSpecificHouse( "@Dolgubon", 36) end, "Visit Maze 1"}
		buttonInfo[#buttonInfo+1] = { function()JumpToSpecificHouse( "@Dolgubon", 9) end, "Visit Maze 2"}
		-- feedbackString = "If you found a bug, have a request or a suggestion, or simply wish to donate, send a mail. You can also check out my house, or donate through Paypal or on Patreon."
	end

	local LibFeedback = LibFeedback
	local button, window = LibFeedback:initializeFeedbackWindow(DolgubonSetCrafter, "Dolgubon's Lazy Set Crafter",DolgubonSetCrafterWindow, "@Dolgubon", 
		{TOPLEFT , DolgubonSetCrafterWindow , TOPLEFT , 10, 10}, 
		buttonInfo, 
		"If you found a bug, have a request or a suggestion, or wish to donate, you can send me a mail here.")
	window:SetHidden(true)

	local currentAPIVersionOfAddon = 101042

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

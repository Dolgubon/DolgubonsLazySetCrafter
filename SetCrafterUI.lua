-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
-- This file sets up the Graphic User Interface for Dolgubon's Lazy Set Crafter (DLSC)
-- Most of these functions are meant to be called by the main file
-- A good portion are setup functions, called by the initialization function
-- 

-- GetRecipeInfo(number recipeListIndex, number recipeIndex)
--  GetRecipeListInfo(number recipeListIndex)

local queue
 

local spacingForButtons = 40


--local original = d local function d() original(pcall(function() error("There's a d() at this line!") end )) end
DolgubonSetCrafter = DolgubonSetCrafter or {}
DolgubonSetCrafter.initializeFunctions = DolgubonSetCrafter.initializeFunctions or {}

local createToggle = DolgubonSetCrafter.createToggle

local debugSelections = {}
DolgubonSetCrafter.debugSelections = debugSelections
local langStrings
local autofillFunctions ={}
DolgubonSetCrafter.autofillFunctionTable = autofillFunctions
--------------------------
-- Setup Functions
-- These functions setup the UI at initialization

-- Common UI element fields:
-- invalidSelection -> If this function returns true, then a default or an invalid selection is selected.
-- selected -> This is normally a table containing both the name of the item selected and the selected index
-- selectPrompt -> If the current selection is invalid, this string will be displayed to tell the user
-- selectDebug -> selects the first valid option, or an easy alternative if the debug mode is on. Largely redundant now with the saved selections


local out = DolgubonSetCrafter.out
--/script d(Dolgubons_Set_Crafter_Style:GetNamedChild( Dolgubons_Set_Crafter_Style:GetChild(1):GetName() ) )

function DolgubonSetCrafter:GetLevel()
	local level = DolgubonSetCrafterWindowInputInputBox:GetText()
	local isCP = DolgubonSetCrafterWindowInputToggleChampion.toggleValue
	if level == "" then
		return nil, isCP
	end
	return tonumber(level), isCP
end

DolgubonSetCrafter.CPToggle = DolgubonSetCrafterWindowInputToggleChampion
DolgubonSetCrafter.levelInput = DolgubonSetCrafterWindowInputInputBox
function DolgubonSetCrafter:GetMultiplier()
	local multiplier = DolgubonSetCrafterWindowMultiplierInputInputBox:GetText()
	if multiplier == "" then
		return 1
	else
		return tonumber(multiplier)
	end
end

-- Most of this is done in the XML, all that's left is to create the toggle and add to the editbox handler
function DolgubonSetCrafter.setupLevelSelector()
	DolgubonSetCrafterWindowInputInputBox:SetTextType(2) -- Set it so it takes only numbers
	DolgubonSetCrafterWindowMultiplierInputInputBox:SetTextType(2)
	createToggle( DolgubonSetCrafterWindowInputToggleChampion ,  [[esoui\art\treeicons\achievements_indexicon_champion_down.dds]], [[esoui\art\treeicons\achievements_indexicon_champion_up.dds]] )

	DolgubonSetCrafterWindowInputToggleChampion.onToggle = function(self, newState)
		DolgubonSetCrafterWindowInputCPLabel:SetHidden(not newState)
		DolgubonSetCrafter.savedvars["champion"] = newState
	end

	DolgubonSetCrafterWindowInputInputBox.selectPrompt = zo_strformat(langStrings.UIStrings.selectPrompt,langStrings.UIStrings.level)
	
	if DolgubonSetCrafter.savedvars.saveLastChoice then
		
		if DolgubonSetCrafter.savedvars["level"] then

			DolgubonSetCrafterWindowInputInputBox:SetText(DolgubonSetCrafter.savedvars["level"])
		end
		if DolgubonSetCrafter.savedvars["champion"]~=nil then
			DolgubonSetCrafterWindowInputToggleChampion:setState(DolgubonSetCrafter.savedvars["champion"])
		end
	end

	if DolgubonSetCrafter.savedvars["level"] and DolgubonSetCrafter.savedvars.saveLastChoice then 
		DolgubonSetCrafterWindowInputInputBox:SetText(DolgubonSetCrafter.savedvars["level"])
	end 
	if DolgubonSetCrafter.savedvars["multiplier"] and DolgubonSetCrafter.savedvars.saveLastChoice then
		DolgubonSetCrafterWindowMultiplierInputInputBox:SetText(DolgubonSetCrafter.savedvars["multiplier"])
	end
	DolgubonSetCrafterWindowComboboxes:adduiElement(DolgubonSetCrafterWindowInput,1 )
	DolgubonSetCrafterWindowComboboxes:adduiElement(DolgubonSetCrafterWindowMultiplierInput, 2)

	debugSelections[#debugSelections+1] = function() DolgubonSetCrafterWindowInputInputBox:SetText("10") end
	debugSelections[#debugSelections+1] = DolgubonSetCrafterWindowInputToggleChampion.ToggleOff
end


function DolgubonSetCrafter.debugFunctions()
	if DolgubonSetCrafter:GetSettings().debug then
		for k, v in pairs(debugSelections) do
			v()
		end
	end
end
function DolgubonSetCrafter.autofillFunctions()
	--if DolgubonSetCrafter:GetSettings().autofill then
		for k, v in pairs(autofillFunctions) do
			v()
		end
	--end
end

function DolgubonSetCrafter.setupLocalizedLabels()
	
	out(langStrings.UIStrings.patternHeader)
	DolgubonSetCrafterWindowComboboxes:SetText 				(langStrings.UIStrings.comboboxHeader)
	DolgubonSetCrafterWindowLeftAdd:SetText 				(langStrings.UIStrings.addToQueue)
	DolgubonSetCrafterWindowInputLevelLabel:SetText 		(langStrings.UIStrings.level..":")
	DolgubonSetCrafterWindowMultiplierInputLabel:SetText 	(langStrings.UIStrings.multiplier..":")
	DolgubonSetCrafterWindowInputCPLabel:SetText 			(langStrings.UIStrings.CP)
	DolgubonSetCrafterWindowLeftResetSelections:SetText		(langStrings.UIStrings.resetToDefault)
	DolgubonSetCrafterWindowLeftClearQueue:SetText 			(langStrings.UIStrings.clearQueue)
	CraftingQueueScrollLabel:SetText 						(langStrings.UIStrings.queueHeader)
	DolgubonSetCrafterWindowLeftCraft:SetText				(langStrings.UIStrings.craftStart)
	DolgubonSetCrafterWindowRightOutputRequirements:SetText (langStrings.UIStrings.chatRequirements)
	DolgubonSetCrafterWindowRightMailRequirements:SetText	(langStrings.UIStrings.mailRequirements)
	DolgubonSetCrafterWindowRightLabel:SetText				(langStrings.UIStrings.materialScrollTitle)
	DolgubonSetCrafterWindowLeftResetPatterns:SetText		(langStrings.UIStrings.resetPatterns)
	DolgubonSetCrafterWindowRightOutputRequest:SetText		(langStrings.UIStrings.chatRequest)
	DolgubonSetCrafterWindowRightMailQueue:SetText			(langStrings.UIStrings.mailRequest)
	DolgubonSetCrafterWindowRightCost:SetText				(langStrings.UIStrings.totalCostTitle)
	DolgubonSetCrafterWindowFavouritesTitle:SetText			(langStrings.UIStrings.FavouritesTitle)
end



function DolgubonSetCrafter.initializeWindowPosition()
	DolgubonSetCrafterWindow:ClearAnchors()
	DolgubonSetCrafterWindow:SetAnchor(TOPLEFT,GuiRoot, TOPLEFT,DolgubonSetCrafter.savedvars.xPos, DolgubonSetCrafter.savedvars.yPos )
	DolgubonSetCrafterToggle:ClearAnchors()
	DolgubonSetCrafterToggle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DolgubonSetCrafter.savedvars.toggleXPos, DolgubonSetCrafter.savedvars.toggleYPos)
	DolgubonSetCrafterWindow:SetDimensions(DolgubonSetCrafter.savedvars.width, DolgubonSetCrafter.savedvars.height)
	DolgubonSetCrafter.dynamicResize(DolgubonSetCrafterWindow)

end

function DolgubonSetCrafter:GetMimicStoneUse()
	return DolgubonSetCrafterWindowLeftTogglesMimicStonesCheckbox.toggleValue
end

function DolgubonSetCrafter:GetAutocraft()
	return DolgubonSetCrafterWindowLeftTogglesAutocraftCheckbox.toggleValue
end

-- Here because we want the craft button to disappear if the autocraft is on
local function FillWithTwoControls(anchorTo, LeftControl, RightControl)
	LeftControl:ClearAnchors()
	RightControl:ClearAnchors()
	LeftControl:SetAnchor(LEFT, anchorTo, LEFT)
	LeftControl:SetAnchor(RIGHT, anchorTo, CENTER)
	RightControl:SetAnchor(LEFT, anchorTo, CENTER)
	RightControl:SetAnchor(RIGHT, anchorTo, RIGHT)
end
local function LeftCenterRightAnchoring(anchorTo, LeftControl,CenterControl,  RightControl)
	LeftControl:ClearAnchors()
	RightControl:ClearAnchors()
	CenterControl:ClearAnchors()
	LeftControl:SetAnchor(BOTTOMLEFT, anchorTo, BOTTOMLEFT)
	CenterControl:SetAnchor(BOTTOM, anchorTo, BOTTOM)
	RightControl:SetAnchor(BOTTOMRIGHT, anchorTo, BOTTOMRIGHT)
end

function DolgubonSetCrafter.toggleCraftButton(toggleOn)
	DolgubonSetCrafterWindowLeftCraft:SetHidden(not toggleOn)
	local mainControl = DolgubonSetCrafterWindowLeftInteractionButtons
	if not toggleOn then
		LeftCenterRightAnchoring(mainControl, DolgubonSetCrafterWindowLeftClearQueue, DolgubonSetCrafterWindowLeftAdd, DolgubonSetCrafterWindowLeftResetSelections )
	else
		FillWithTwoControls(mainControl:GetNamedChild("PositionLeft"), DolgubonSetCrafterWindowLeftClearQueue, DolgubonSetCrafterWindowLeftAdd)
		FillWithTwoControls(mainControl:GetNamedChild("PositionRight"), DolgubonSetCrafterWindowLeftCraft, DolgubonSetCrafterWindowLeftResetSelections)
	end
end


function DolgubonSetCrafter.setupBehaviourToggles()
	-- Set initial to true
	local autoCraft = DolgubonSetCrafterWindowLeftTogglesAutocraftCheckbox
	local mimicStones = DolgubonSetCrafterWindowLeftTogglesMimicStonesCheckbox

	DolgubonSetCrafter.createToggle(autoCraft,"esoui/art/cadwell/checkboxicon_checked.dds",	"esoui/art/cadwell/checkboxicon_unchecked.dds", 
		"esoui/art/cadwell/checkboxicon_unchecked.dds", "esoui/art/cadwell/checkboxicon_checked.dds", true )
	DolgubonSetCrafter.createToggle(mimicStones,"esoui/art/cadwell/checkboxicon_checked.dds", "esoui/art/cadwell/checkboxicon_unchecked.dds", 
		"esoui/art/cadwell/checkboxicon_unchecked.dds", "esoui/art/cadwell/checkboxicon_checked.dds", false )

	autoCraft:GetNamedChild("Label"):SetText(DolgubonSetCrafter.localizedStrings.UIStrings.autoCraft)
	mimicStones:GetNamedChild("Label"):SetText(DolgubonSetCrafter.localizedStrings.UIStrings.mimicStones)

	if DolgubonSetCrafter.savedvars.saveLastChoice then
		autoCraft:setState(DolgubonSetCrafter.savedvars["autoCraft"])
		DolgubonSetCrafter.toggleCraftButton( false)
		mimicStones:setState(DolgubonSetCrafter.savedvars["mimicStones"])
	else
	end


	autoCraft.onToggle = function(self, newState) 
		DolgubonSetCrafter.savedvars['autoCraft'] = newState
		DolgubonSetCrafter.LazyCrafter:SetAllAutoCraft(newState)
		DolgubonSetCrafter.LazyCrafter:craftInteract()
		if GetCraftingInteractionType() == 0 then return end
		DolgubonSetCrafter.toggleCraftButton(not newState)

	end

	mimicStones.onToggle = function(self, newState) 
		DolgubonSetCrafter.savedvars['mimicStones'] = newState 
	end
end


-- UI setup directing function
function DolgubonSetCrafter.initializeFunctions.setupUI()
	langStrings = DolgubonSetCrafter.localizedStrings
	queue = DolgubonSetCrafter.savedvars.queue -- Retreive the queue from saved variables

	DolgubonSetCrafter.setupLocalizedLabels()
	DolgubonSetCrafter.setupPatternButtons() -- check
	DolgubonSetCrafter.setupComboBoxes() -- check
	DolgubonSetCrafter.setupLevelSelector() --check
	DolgubonSetCrafter.setupBehaviourToggles()


	DolgubonSetCrafter.setupScrollLists()
	

	--DolgubonSetCrafter.debugFunctions()
	DolgubonSetCrafter.initializeWindowPosition()
	DolgubonSetCrafterToggle:SetHidden(not DolgubonSetCrafter:GetSettings().showToggle )
	DolgubonSetCrafterWindowComboboxes:anchoruiElements(DolgubonSetCrafterWindowInput,1 )
	DolgubonSetCrafter.manager:RefreshData() -- Show the scroll
	DolgubonSetCrafter.materialManager:RefreshData()
	DolgubonSetCrafter.favouritesManager:RefreshData()
	local includeFlags = { AUTO_COMPLETE_FLAG_ALL}
	ZO_AutoComplete:New(DolgubonSetCrafterWindowRightInputBox, includeFlags, {}, AUTO_COMPLETION_ONLINE_OR_OFFLINE, 5)
	if not DolgubonSetCrafter:GetSettings().initialFurniture then
		DolgubonSetCrafterWindowFavourites:SetHidden(not DolgubonSetCrafter:GetSettings().showFavourites )
	end
	if DolgubonSetCrafter:GetSettings().initialFurniture then
		DolgubonSetCrafter.toggleFurnitureUI(DolgubonSetCrafterWindowToggleFurniture)
	end

end


---------------------
--- OTHER


function DolgubonSetCrafter.resetChoices()

	for i = 1, #DolgubonSetCrafter.patternButtons do
		DolgubonSetCrafter.patternButtons[i]:toggleOff()
	end
	for k, comboBoxContainer in pairs(DolgubonSetCrafter.ComboBox) do
		comboBoxContainer:SelectFirstItem()
	end
	DolgubonSetCrafterWindowInputInputBox:SetText("")
	DolgubonSetCrafterWindowMultiplierInputInputBox:SetText("1")
end

function DolgubonSetCrafter.resetPatterns()
	for i = 1, #DolgubonSetCrafter.patternButtons do
		DolgubonSetCrafter.patternButtons[i]:toggleOff()
	end
end

function DolgubonSetCrafter.onWindowMove(window)
	
	DolgubonSetCrafter.savedvars.xPos = window:GetLeft()
	DolgubonSetCrafter.savedvars.yPos = window:GetTop()
end
DolgubonSetCrafter.defaultWidth = 1150
DolgubonSetCrafter.defaultHeight = 650
local totalWindowWidth = DolgubonSetCrafter.defaultWidth
local leftHalfWindowWidth = totalWindowWidth - DolgubonSetCrafter.localizedMatScrollWidth
local function getDividerPosition(window, a)
	local DIVIDER_RATIO = leftHalfWindowWidth/totalWindowWidth
	local width = window:GetWidth()
	local divider = window:GetNamedChild("Divider")

	divider:ClearAnchors()
	local offsetX = DIVIDER_RATIO*width
	if a%30 == 0 then
		--d(width)
		--d(offsetX)
	end
	divider:SetAnchor(BOTTOMLEFT ,window, BOTTOMLEFT, offsetX,-3)
	divider:SetAnchor(TOPLEFT ,window, TOPLEFT, offsetX,2)
	divider:SetDimensions(4, window:GetHeight())
end

local a = 1 
--<DimensionConstraints minX="700" minY="460" />
-- 700
local function SetWindowScale(window, scale)
	local LeftRightRatio =  leftHalfWindowWidth/totalWindowWidth
	local divider = window:GetNamedChild("divider")
	local left = window:GetNamedChild("Left")
	local right = window:GetNamedChild("Right")
	local newScale = window:GetWidth()/totalWindowWidth
	newScale = math.min(newScale, 1) -- after 1, don't rescale it anymore
	-- Rather than changing the scale of the whole window (which will change the size and call this again)
	-- we scale the two main elements of the window so that they match the size
	left:SetScale(newScale)
	right:SetScale(newScale)
	DolgubonSetCrafterWindowPatternInput:ClearAnchors()
	DolgubonSetCrafterWindowPatternInput:SetAnchor(TOPLEFT, DolgubonSetCrafterWindowOutput, BOTTOMLEFT, 0, 0)
	DolgubonSetCrafterWindowPatternInput:SetAnchor(BOTTOMRIGHT, DolgubonSetCrafterWindowOutput, BOTTOMRIGHT, 0, newScale*110)
	DolgubonSetCrafterWindowClose:SetScale(newScale)
	-- Change the new minimum height as required
	DolgubonSetCrafterWindow:SetDimensionConstraints(740, 520*(1 - (1 - newScale)/2))

	
	

end

local minXBeforeResize = 995
local minYBeforeResize = 520
function DolgubonSetCrafter.dynamicResize(window)
	a = a + 1
	-- Resize method 1
	getDividerPosition(window, a)
	DolgubonSetCrafter.manager:RefreshData() -- Show the scroll
	DolgubonSetCrafter.materialManager:RefreshData()
	
	-- Resize method 2
	local newScale = (totalWindowWidth - window:GetWidth())*(-0.0008) + 1
	local scale = math.sqrt(window:GetWidth()/totalWindowWidth)
	SetWindowScale(window, scale)
	if true or window:GetWidth() > totalWindowWidth then return end
	newScale = math.min(newScale, 1.5)
	newScale = math.max(newScale, 0.8)

	window:SetScale(newScale)
end
DolgubonSetCrafter.dynamic = dynamicResize
-- /script DolgubonSetCrafterWindow:SetWidth(800) DolgubonSetCrafter.dynamic(DolgubonSetCrafterWindow)
function DolgubonSetCrafter.onWindowResizeStart(window)

	EVENT_MANAGER:RegisterForUpdate(DolgubonSetCrafter.name.."WindowResize",10, function()DolgubonSetCrafter.dynamicResize(window) end)
	window:BringWindowToTop()

end

function DolgubonSetCrafter.onWindowResizeStop(window)

	EVENT_MANAGER:UnregisterForUpdate(DolgubonSetCrafter.name.."WindowResize")
	DolgubonSetCrafter.savedvars.width = DolgubonSetCrafterWindow:GetWidth()
	DolgubonSetCrafter.savedvars.height = DolgubonSetCrafterWindow:GetHeight()
end

--esoui/art/journal/gamepad/gp_journalcheck.dds
--esoui/art/buttons/decline_up.dds
--esoui/art/buttons/accept_up.dds


---------- X buttons, for getting out of the window
--esoui/art/buttons/decline_down.dds
--esoui/art/buttons/decline_up.dds
--esoui/art/buttons/decline_over.dds

----------- Checked and Unchecked Boxes
--esoui/art/cadwell/checkboxicon_checked.dds
--esoui/art/cadwell/checkboxicon_unchecked.dds

----------- Set Button
--esoui/art/crafting/smithing_tabicon_armorset_disabled.dds
--esoui/art/crafting/smithing_tabicon_armorset_over.dds
--esoui/art/crafting/smithing_tabicon_armorset_up.dds
--esoui/art/crafting/smithing_tabicon_armorset_down.dds

---------- Champion symbols
--esoui\art\treeicons\achievements_indexicon_champion_down.dds
--esoui\art\treeicons\achievements_indexicon_champion_over.dds
--esoui\art\treeicons\achievements_indexicon_champion_up.dds

--[[
esoui/art/characterwindow/gearslot_offhand.dds
esoui/art/characterwindow/gearslot_mainhand.dds
esoui/art/characterwindow/gearslot_chest.dds
esoui/art/characterwindow/gearslot_feet.dds
esoui/art/characterwindow/gearslot_hands.dds
esoui/art/characterwindow/gearslot_head.dds
esoui/art/characterwindow/gearslot_legs.dds
esoui/art/characterwindow/gearslot_shoulders.dds
esoui/art/characterwindow/gearslot_belt.dds


esoui/art/race/silhouette_human_female.dds


|H1:item:43543:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:44241:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43545:20:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43545:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
/script d(ZO_LinkHandler_CreateLink(nil, nil, ITEM_LINK_TYPE, 43544, i, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0))

lvl 1 shoes
|H1:item:43544:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h white
|H1:item:43544:31:1:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h green
|H1:item:43544:32:1:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h blue
|H1:item:43544:33:1:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h purple
|H1:item:43544:34:1:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h gold

lvl 4 shoes
|H1:item:43544:25:4:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:26:4:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:27:4:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:28:4:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:29:4:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h

lvl 6 shoes
|H1:item:43544:20:6:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h

lvl 8 shoes
|H1:item:43544:20:8:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h

|H1:item:43544:20:10:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:12:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:14:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:18:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:16:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:24:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:24:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:40:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:20:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h

|H1:item:44241:25:4:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h

Gloves
|H1:item:43544:125:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP10
|H1:item:43544:126:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP20
|H1:item:43544:127:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP30
|H1:item:43545:128:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP40
|H1:item:43545:129:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP50
|H1:item:43545:131:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP70
|H1:item:43545:132:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP 80
|H1:item:43545:133:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP90
|H1:item:43545:134:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP100
|H1:item:43545:236:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP110
|H1:item:43545:254:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP120
|H1:item:43545:272:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP130
|H1:item:43545:290:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP140
|H1:item:43545:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP150
|H1:item:43545:366:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP160

Shoes
|H1:item:43544:125:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP10
|H1:item:43544:133:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP90
|H1:item:43544:366:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h CP160

Shoes CP 150
|H1:item:43544:309:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:310:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:311:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43544:312:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h

Quality Number
lvl 1: 30 + quality
lvl 4: 25 + quality
lvl 6-50: 20 + quality
CP10 - 100: 124 + CP/10
CP110 - CP 150: 236 + 18(per 10CP over 110) + quality
CP160: 366  + quality
236, 254, 272, 290, 308, 366

Intricate CP160 Jerkin
|H1:item:45352:366:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:10000:0|h|h
|H1:item:45352:359:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:10000:0|h|h
|H1:item:45352:362:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:10000:0|h|h
|H1:item:45352:363:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:10000:0|h|h
|H1:item:45352:364:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:10000:0|h|h

Intricate CP160 Sash
|H1:item:45354:365:50:0:0:0:0:0:0:0:0:0:0:0:0:3:0:0:0:10000:0|h|h
|H1:item:45354:359:50:0:0:0:0:0:0:0:0:0:0:0:0:3:0:0:0:10000:0|h|h
|H1:item:45354:362:50:0:0:0:0:0:0:0:0:0:0:0:0:3:0:0:0:10000:0|h|h
|H1:item:45354:363:50:0:0:0:0:0:0:0:0:0:0:0:0:3:0:0:0:10000:0|h|h
|H1:item:45354:364:50:0:0:0:0:0:0:0:0:0:0:0:0:3:0:0:0:10000:0|h|h

CP160 Robe
|H1:item:43543:366:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43543:367:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43543:368:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43543:369:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:43543:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h

CP160 Twice Born Star Robe
|H1:item:58174:366:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:58174:367:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:58174:368:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:58174:369:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h
|H1:item:58174:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h

|H1:item:58174:366:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:58168:366:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:58173:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:58170:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:58167:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h

|H1:item:43543:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:44241:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43544:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:43545:308:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h


<Label name="$(parent)Name" font="ZoFontGameShadow" wrapMode="ELLIPSIS" verticalAlignment="CENTER">
]]

-- Check out ZO_StatsDropdownRow
--local myFragment = ZO_FadeSceneFragment:New(myControl, nil, 0)
--someScene:AddFragment(myFragment)
--[[there is no specific scene for each menu
you just need to add it to the correct scene in response to LAM callbacks
SCENE_MANAGER:GetScene("gameMenuInGame")
in "LAM-PanelOpened" you call AddFragment and in LAM-PanelClosed you call RemoveFragment IF the panel passed to the callback is your menu
on panel closed you would then also add the fragment back to your original scene (crafting station)
or maybe you can even leave it there. no idea
have never tried to add the same fragment to multiple scenes


]]
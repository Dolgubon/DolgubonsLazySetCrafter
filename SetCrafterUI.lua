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
--local original = d local function d() original(pcall(function() error("There's a d() at this line!") end )) end
DolgubonSetCrafter = DolgubonSetCrafter or {}
DolgubonSetCrafter.initializeFunctions = DolgubonSetCrafter.initializeFunctions or {}

local createToggle = DolgubonSetCrafter.createToggle

local DolgubonScroll = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.scroll = DolgubonScroll

local MaterialScroll = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.MaterialScroll = MaterialScroll
DolgubonSetCrafter.materialList = DolgubonSetCrafter.materialList or {}

local updateList = function() end
local updateMaterials = function() end
local debugSelections = {}
local langStrings
local autofillFunctions ={}
--------------------------
-- Setup Functions

local pieceNames = 
{
	"Chest","Feet","Hands","Head","Legs","Shoulders","Belt","Jerkin"
}

local weaponNames = 
{
	"Axe", "Mace", "Sword", "Battle Axe", "Maul", "Greatsword", "Dagger", "Bow", "Fire Staff", "Ice Staff", "Lightning Staff", "Restoration Staff", "Shield"
}

local armourTypes = 
{
	"Heavy", "Medium", "Light"
}

local queue
 

local spacingForButtons = 40
local function setupPatternButtonOneTable(table,nameTable, initialX, initialY, positionToSave)
	for k, v in pairs (table) do
		-- Create the pattern button

		local index = #positionToSave + 1
		positionToSave[index] = WINDOW_MANAGER:CreateControlFromVirtual("DolgubonsSetCrafterPatternInput"..v, 
			DolgubonSetCrafterWindowPatternInput, "PieceButtonTemplate")
		--[[	-- container to easily reference the labels
			local toonNameDisplays = {}
			-- The next item to anchor to
			local anchorLabel = StonedDis
			for i = 1, 5 do
				-- Create the virtual control
				local currentDisplay = WINDOW_MANAGER:CreateControlFromVirtual(StonedDis:GetName()..i, StonedDis, "DisplayTemplate")
				-- Set the anchor of the new control
				currentDisplay:SetAnchor(TOPLEFT ,anchorLabel , TOPLEFT ,0,0)
				-- The next control will be anchored to this new control
				anchorLabel = currentDisplay
				-- Add the control to the table
				toonNameDisplays[#toonNameDisplays] = currentDisplay
			end]]
		-- Easy reference
		local button = positionToSave[index]
		button.tooltip = nameTable[k]
		button.selectedIndex = k
		-- Create the toggle
		local locationPart = string.lower(string.gsub(string.gsub(v, " Staff", ""), " ", ""))
		if v=="Jerkin" then 
			locationPart= "chest" 
			button:SetDimensions(36, 36)
			button:SetHidden(true)
		end
		if v=="Head" or v=="Heavy" then
			createToggle(button,"EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds", 
				"EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds" , 
				"EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
				"EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
				false)
		else
			createToggle(button,[[DolgubonsLazySetCrafter/images/patterns/]]..locationPart.."_down.dds", 
				[[DolgubonsLazySetCrafter/images/patterns/]]..locationPart.."_up.dds" , 
				[[DolgubonsLazySetCrafter/images/patterns/]]..locationPart.."_over.dds" ,
				[[DolgubonsLazySetCrafter/images/patterns/]]..locationPart.."_over.dds",
				false)
		end
		button:toggleOff() 

		button:SetAnchor(CENTER , DolgubonSetCrafterWindowPatternInput , CENTER , initialX + index*spacingForButtons, initialY)
		--button:SetAnchor(CENTER , DolgubonSetCrafterWindowPatternInputPerson , CENTER , 
			--(-1)*60*((-1)^(index))*math.ceil(1 - 1/index), -160 +math.floor(index /2)*50 + math.floor(index/8)*50)
		-- Inital text of the label; meant to be overwritten
		

		-- Called when the user enters a station. Selectively hides or shows the button if it's at a station where it's useful
		function button:PrepareForStation(station, set)

			-- Gets the name of the type of equipment, and gives that to the label.
		end
	end
end


-- Sets up the pattern buttons (for info on patterns, see ConstantSetup.lua)
function DolgubonSetCrafter.setupPatternButtons()


	-- Table to hold all the pattern buttons
	DolgubonSetCrafter.patternButtons = {}
	DolgubonSetCrafter.armourTypes = {}

	setupPatternButtonOneTable(pieceNames 	,langStrings.pieceNames			,  -400 					, 40 , DolgubonSetCrafter.patternButtons)
	setupPatternButtonOneTable(weaponNames	,langStrings.weaponNames		, -400-spacingForButtons*8 	, 85 , DolgubonSetCrafter.patternButtons)
	setupPatternButtonOneTable(armourTypes	,langStrings.armourTypes		,  150					 	, 40 , DolgubonSetCrafter.armourTypes)
	DolgubonSetCrafter.armourTypes[1]:toggle()

	debugSelections[#debugSelections+1] = function() DolgubonSetCrafter.patternButtons[1]:toggle() end

	local function setOtherArmourTypesToZero(index)
		for i = 1, #DolgubonSetCrafter.armourTypes do
			if index ~= i then
				DolgubonSetCrafter.armourTypes[i]:toggleOff(true)
			end
		end
	end

	for i = 1, #DolgubonSetCrafter.armourTypes do
		local button = DolgubonSetCrafter.armourTypes[i]
		local original = button.toggleOff
		function button:toggleOff(activate)
			if activate then 
				original(button)
			end
		end
		function button:toggleOn()
			self.toggleValue = true
			self:SetNormalTexture(self.onTexture)
			if onOverTexture then self:SetMouseOverTexture(self.onOverTexture) end
			setOtherArmourTypesToZero(i)
			if i == 3 then
				DolgubonsSetCrafterPatternInputJerkin:SetHidden(false)
			else
				DolgubonsSetCrafterPatternInputJerkin:toggleOff()
				DolgubonsSetCrafterPatternInputJerkin:SetHidden(true)
			end

		end
	end
end


function DolgubonSetCrafter.out(text)
	DolgubonSetCrafterWindowOutput:SetText(text)
end

local out = DolgubonSetCrafter.out
--/script d(Dolgubons_Set_Crafter_Style:GetNamedChild( Dolgubons_Set_Crafter_Style:GetChild(1):GetName() ) )

--Creates one dropdown box
local function makeDropdownSelections(comboBoxContainer, tableInfo , text , x, y, comboBoxLocation, isArmourCombobox)
	local comboBox = comboBoxContainer:GetChild(comboBoxLocation)
	-- if location is 1 then get child number 2 and if location is 2 get child number 1
	comboBoxContainer:GetChild((comboBoxLocation+2)%2+1):SetText(text..":")
	if not comboBox.m_comboBox then 
		comboBox.m_comboBox =comboBox.dropdown
		comboBox.dropdown.m_container:SetDimensions(200,30)
		comboBox.dropdown.m_dropdown:SetDimensions(200,370)
	end
	--Function called when an option is selected
	function comboBox:setSelected(comboBox, selectedInfo)

		--out(selectedInfo[2].." selected.")
		selectedInfo[2] =zo_strformat("<<t:1>>",selectedInfo[2])
		comboBox.m_comboBox.selectedIndex = selectedInfo[1]
		comboBox.m_comboBox.selectedName = selectedInfo[2]
		comboBox.m_comboBox:HideDropdownInternal()
		comboBoxContainer.selected = selectedInfo
		comboBoxContainer.invalidSelection = function(weight)
			
			if isArmourCombobox==nil then return selectedInfo[1]==-1
			elseif weight =="" then
				
				if isArmourCombobox then
					
					return false 
				else
					
					return selectedInfo[1]==-1 
				end
			elseif not isArmourCombobox then -- Armour piece is selected
				
				return false
			else 
				
				return selectedInfo[1]==-1
			end	
		end
	end

	--comboBox.m_comboBox.SelectFirstItem = function() Dolgubons_Guild_Blacklist_Selecter.m_comboBox:SelectItem(Dolgubons_Guild_Blacklist_Selecter.m_comboBox.allGuilds) end
	comboBox.m_comboBox:SetSortsItems(false)
	comboBox.itemEntryDefault = ZO_ComboBox:CreateItemEntry(zo_strformat(langStrings.UIStrings.comboboxDefault,text), function() 
		comboBox:setSelected(comboBox, {-1,zo_strformat(langStrings.UIStrings.comboboxDefault ,text)})
			end )
	comboBox.m_comboBox:AddItem(comboBox.itemEntryDefault)
	comboBoxContainer.selectPrompt = zo_strformat(langStrings.UIStrings.selectPrompt,text)

	function comboBoxContainer:SelectFirstItem()
		comboBox.m_comboBox:SelectItem(comboBox.itemEntryDefault) 
	end

	for i, value in pairs(tableInfo) do
		local itemEntry = ZO_ComboBox:CreateItemEntry(zo_strformat("<<t:1>>",tableInfo[i][2]), function() comboBox:setSelected(comboBox, tableInfo[i])end )
		
		comboBox.m_comboBox:AddItem(itemEntry)

		if i == 1 or tableInfo[i][2] == "|cFFFFFFAncient Elf|r" then
			function comboBoxContainer:SelectDebug()
				comboBox.m_comboBox:SelectItem(itemEntry)
			end
			debugSelections[#debugSelections+1] = function() comboBoxContainer:SelectDebug() end
			function comboBoxContainer:SelectAutoFill()
				if self.name~="Style" and comboBoxContainer.invalidSelection(requestTable["Weight"]) and DolgubonSetCrafter.savedVars.autofill then
					comboBox.m_comboBox:SelectItem(itemEntry)
				end
			end
			debugSelections[#debugSelections+1] = function() comboBoxContainer:SelectDebug() end

			autofillFunctions[#autofillFunctions + 1] = function() comboBoxContainer:SelectAutoFill() end
		end
	end

	comboBoxContainer:SelectFirstItem()
	--set size + position
	comboBoxContainer:SetAnchor(CENTER,  DolgubonSetCrafterWindowComboboxes,CENTER, x,y)

	--make the selection
	comboBox.m_comboBox:SetSelectedItemFont("ZoFontGameMedium")
	comboBox.m_comboBox:SetDropdownFont("ZoFontGameMedium")

end

-- Sets up the different combo boxes
function DolgubonSetCrafter.setupComboBoxes()
	--initial creation of blank combo boxes
	-- Note: Could be combined into a loop or something, but left like this for clarity
	DolgubonSetCrafter.ComboBox = {}
	DolgubonSetCrafter.ComboBox.Style 		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Style", DolgubonSetCrafterWindowComboboxes, "ScrollComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Armour 		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Armour_Trait", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Weapon 		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Weapon_Trait", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Quality		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Quality", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Set			= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Set", DolgubonSetCrafterWindowComboboxes, "ScrollComboboxTemplate")
	for k, v in pairs(DolgubonSetCrafter.ComboBox) do
		v.name = k
	end
	local UIStrings = langStrings.UIStrings
	--Three calls to make dropdown selections, as well as further setup the comboboxes.
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Style  	   	, DolgubonSetCrafter.styleNames   , UIStrings.style 		, -130, 80, 2)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Armour 		, DolgubonSetCrafter.armourTraits , UIStrings.armourTrait 	, -130, 120, 1, true)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Quality	   	, DolgubonSetCrafter.quality 	  , UIStrings.quality 		, 270 , 80, 1)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Weapon 		, DolgubonSetCrafter.weaponTraits , UIStrings.weaponTrait 	, 270 , 120, 1, false)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Set  	   	, DolgubonSetCrafter.setIndexes   , UIStrings.gearSet 		, 270, 40, 2)
end

-- Most of this is done in the XML, all that's left is to create the toggle and add to the editbox handler
function DolgubonSetCrafter.setupLevelSelector()
	DolgubonSetCrafterWindowInputBox:SetTextType(2) -- Set it so it takes only numbers
	createToggle( DolgubonSetCrafterWindowInputToggleChampion , [[esoui\art\treeicons\achievements_indexicon_champion_up.dds]] , [[esoui\art\treeicons\achievements_indexicon_champion_down.dds]], false)
	DolgubonSetCrafterWindowInputToggleChampion.onToggleOff =function() DolgubonSetCrafterWindowInputCPLabel:SetHidden(false) end
	DolgubonSetCrafterWindowInputToggleChampion.onToggleOn =function() DolgubonSetCrafterWindowInputCPLabel:SetHidden(true) end
	DolgubonSetCrafterWindowInputBox.selectPrompt = zo_strformat(langStrings.UIStrings.selectPrompt,langStrings.UIStrings.level)
	debugSelections[#debugSelections+1] = function() DolgubonSetCrafterWindowInputBox:SetText("10") end
	debugSelections[#debugSelections+1] = DolgubonSetCrafterWindowInputToggleChampion.ToggleOff
end


function DolgubonScroll:New(control)

	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		Reference = {},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "CraftingRequestTemplate", 30, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "Reference"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "Reference", SorterKeys, self.currentSortOrder) end
	self.data = queue
	return self
	
end

function MaterialScroll:New(control)

	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		Amount = {},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "SetCrafterMaterialTemplate", 30, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "Reference"
	self.currentSortOrder = ZO_SORT_ORDER_DOWN
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "Amount", SorterKeys, self.currentSortOrder) end
	self.data = DolgubonSetCrafter.materialList
	return self
	
end

function MaterialScroll:SetupEntry(control, data)

	control.data = data
	for k , v in pairs(data[1]) do
		control[k] = GetControl(control, k)

		if control[k] then
			if type(v)=="table" then
				control[k]:SetText(v[2])
				control[k]:SetColor(1,1,0)

				control[k]:ApplyColour(v[3])
			else
				control[k]:SetText(v)
			end
		end
	end
	
	ZO_SortFilterList.SetupRow(self, control, data)
end

local function removeFauxRequest(reference)
	for i = 1, #queue do 

		if queue[i]["reference"]==reference then
			table.remove( queue, i)
			return
		end
	end
end

function DolgubonScroll:SetupEntry(control, data)

	control.data = data
	for k , v in pairs (data[1]) do
		control[k] = GetControl(control, k)

		if control[k] then
			if type(v)=="table" then
				control[k]:SetText(v[2])
				control[k]:SetColor(1,1,0)

				control[k]:ApplyColour(v[3])
			else
				control[k]:SetText(v)
			end
		end
	end

	button = control:GetNamedChild( "RemoveButton")

	function button:onClickety ()   DolgubonSetCrafter.removeFromScroll(data[1].Reference)  end
	--function control:onClicked () DolgubonsGuildBlacklistWindowInputBox:SetText(data.name) end
	
	ZO_SortFilterList.SetupRow(self, control, data)
	
end


function DolgubonScroll:BuildMasterList()
	self.masterList = {}

	for k, v in pairs(self.data) do 

		table.insert(self.masterList, {
			v
		})

	end

end

function DolgubonScroll:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end


function DolgubonScroll:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

MaterialScroll.BuildMasterList = DolgubonScroll.BuildMasterList
MaterialScroll.SortScrollList = DolgubonScroll.SortScrollList
MaterialScroll.FilterScrollList = DolgubonScroll.FilterScrollList

function DolgubonSetCrafter.debugFunctions()
	if DolgubonSetCrafter.savedVars.debug then
		for k, v in pairs(debugSelections) do
			v()
		end
	end
end
function DolgubonSetCrafter.autofillFunctions()
	--if DolgubonSetCrafter.savedVars.autofill then
		for k, v in pairs(autofillFunctions) do
			v()
		end
	--end
end

function DolgubonSetCrafter.setupLocalizedLabels()
	DolgubonSetCrafterWindowPatternInput:SetText 	(langStrings.UIStrings.patternHeader)
	DolgubonSetCrafterWindowComboboxes:SetText 		(langStrings.UIStrings.comboboxHeader)
	DolgubonSetCrafterWindowAdd:SetText 			(langStrings.UIStrings.addToQueue)
	DolgubonSetCrafterWindowInputLevelLabel:SetText (langStrings.UIStrings.level)
	DolgubonSetCrafterWindowInputCPLabel:SetText 	(langStrings.UIStrings.CP)
	DolgubonSetCrafterWindowResetSelections:SetText (langStrings.UIStrings.resetToDefault)
	DolgubonSetCrafterWindowClearQueue:SetText 		(langStrings.UIStrings.clearQueue)
	CraftingQueueScrollLabel:SetText 				(langStrings.UIStrings.queueHeader)
end



function DolgubonSetCrafter.initializeWindowPosition()
	DolgubonSetCrafterWindow:ClearAnchors()
	
	DolgubonSetCrafterWindow:SetAnchor(TOPLEFT,GuiRoot, TOPLEFT,DolgubonSetCrafter.savedVars.xPos, DolgubonSetCrafter.savedVars.yPos )
end

-- UI setup directing function
function DolgubonSetCrafter.initializeFunctions.setupUI()
	langStrings = DolgubonSetCrafter.localizedStrings
	queue = DolgubonSetCrafter.savedVars.queue -- Retreive the queue from saved variables

	DolgubonSetCrafter.setupLocalizedLabels()
	DolgubonSetCrafter.setupPatternButtons() -- check
	DolgubonSetCrafter.setupComboBoxes() -- check
	DolgubonSetCrafter.setupLevelSelector() --check

	DolgubonSetCrafter.manager = DolgubonScroll:New(CraftingQueueScroll) -- check
	DolgubonSetCrafter.manager:RefreshData() -- Show the scroll
	
	
	DolgubonSetCrafter.materialManager = MaterialScroll:New(DolgubonSetCrafterWindowMaterialList)
	DolgubonSetCrafter.materialManager:RefreshData()

	DolgubonSetCrafter.debugFunctions()
	DolgubonSetCrafter.initializeWindowPosition()
end



updateList = function () 
	DolgubonSetCrafter.manager:RefreshData()
	DolgubonSetCrafter.materialManager:RefreshData()
	if #queue == 0 then 
		CraftingQueueScrollCounter:SetText()
	else
		CraftingQueueScrollCounter:SetText(" - "..#queue)
	end
 end
DolgubonSetCrafter.updateList = updateList


---------------------
--- OTHER

function DolgubonSetCrafter.resetChoices()

	for i = 1, #DolgubonSetCrafter.patternButtons do
		DolgubonSetCrafter.patternButtons[i]:toggleOff()
	end
	for k, comboBoxContainer in pairs(DolgubonSetCrafter.ComboBox) do
		comboBoxContainer:SelectFirstItem()
	end
	DolgubonSetCrafterWindowInputBox:SetText("")
end

function DolgubonSetCrafter.onWindowMove(window)
	
	DolgubonSetCrafter.savedVars.xPos = window:GetLeft()
	DolgubonSetCrafter.savedVars.yPos = window:GetTop()
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
have never tried to add the same fragment to multiple scenes]]
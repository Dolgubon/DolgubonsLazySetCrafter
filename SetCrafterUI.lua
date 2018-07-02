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
-- These functions setup the UI at initialization

-- Common UI element fields:
-- invalidSelection -> If this function returns true, then a default or an invalid selection is selected.
-- selected -> This is normally a table containing both the name of the item selected and the selected index
-- selectPrompt -> If the current selection is invalid, this string will be displayed to tell the user
-- selectDebug -> selects the first valid option, or an easy alternative if the debug mode is on. Largely redundant now with the saved selections


local pieceNames = 
{
	"spaceHalf","Chest","Feet","Hands","Head","Legs","Shoulders","Belt","Jerkin", "space"
}

local jewelryNames =
{
	"Ring", "Neck", "space", "space"
}

local weaponNames = 
{
	"space","space","Axe", "Mace", "Sword", "BattleAxe", "Maul", "Greatsword", "Dagger", "Bow", "Fire", "Ice", "Lightning", "Restoration", "Shield"
}

local armourTypes = 
{
	"Heavy", "Medium", "Light"
}

local queue
 

local spacingForButtons = 40

-- A shortcut to output info to the user
function DolgubonSetCrafter.out(text)
	if text == "" then
		DolgubonSetCrafterWindowOutput:SetHidden(true)
	else
		DolgubonSetCrafterWindowOutput:SetText(text)
		DolgubonSetCrafterWindowOutput:SetHidden(false)
	end
end

function DolgubonSetCrafter:GetWeight()
	local weight = DolgubonSetCrafter.armourTypes.weight
	return weight, DolgubonSetCrafter.armourTypes[weight].tooltip
end


local function setupPatternButtonFunctions(patternButtons)
	for i = 1, 8 do -- Armour, made to fit
		patternButtons[i].GetStation = function() 
			if DolgubonSetCrafter:GetWeight() == 1 then 
				return CRAFTING_TYPE_BLACKSMITHING 
			else
				return CRAFTING_TYPE_CLOTHIER
			end
		end
		patternButtons[i].UseStyle = function() return true end
		patternButtons[i].TraitsToUse = function()return DolgubonSetCrafter.ComboBox.Armour end
		patternButtons[i].HaveWeights = function() return true end
		patternButtons[i].GetPattern = function(self, weightOverride)

			local weight = weightOverride or DolgubonSetCrafter:GetWeight() 

			if weight ~=3 and i == 8 then return 0 end
			
			if weight == 1 then
				return i + 7
			elseif weight == 2 then
				return i + 8
			else
				if i == 8 then return 2 end
				if i == 1 then return 1 end
				return i + 1
			end

		end
	end
	for i = 9, 10 do -- ring + neck
		patternButtons[i].GetStation = function() return CRAFTING_TYPE_JEWELRYCRAFTING end
		patternButtons[i].UseStyle = function() return false end
		patternButtons[i].TraitsToUse = function() return DolgubonSetCrafter.ComboBox.Jewelry end
		patternButtons[i].HaveWeights = function() return false end
		patternButtons[i].GetPattern = function() return i - 8 end
	end
	for i = 11, 17 do -- blacksmithing weapons
		patternButtons[i].GetStation = function() return CRAFTING_TYPE_BLACKSMITHING end
		patternButtons[i].UseStyle = function() return true end
		patternButtons[i].TraitsToUse = function() return DolgubonSetCrafter.ComboBox.Weapon end
		patternButtons[i].HaveWeights = function() return false end
		patternButtons[i].GetPattern = function() return i - 10 end
	end
	for i = 18, 22 do -- woodworking weapons
		patternButtons[i].GetStation = function() return CRAFTING_TYPE_WOODWORKING end
		patternButtons[i].UseStyle = function() return true end
		patternButtons[i].TraitsToUse = function() return DolgubonSetCrafter.ComboBox.Weapon end
		patternButtons[i].HaveWeights = function() return false end
		patternButtons[i].GetPattern = function() if i == 18 then return 1 else return i - 16 end end
	end
	local i = 23
	patternButtons[i].GetStation = function() return CRAFTING_TYPE_WOODWORKING end
	patternButtons[i].UseStyle = function() return true end
	patternButtons[i].TraitsToUse = function()return DolgubonSetCrafter.ComboBox.Armour end
	patternButtons[i].HaveWeights = function() return false end
	patternButtons[i].GetPattern = function() return 2 end
end


local numSpacers = 0
-- Sets up pattern buttons for weaponNames, armourTypes and pieceNames
-- Since it's only three tables, some of it is hardcoded using if statements.
local function setupPatternButtonOneTable(table,nameTable, initialX, initialY, positionToSave, parent)
	local lastButton = nil
	local count= 0
	for k, v in pairs (table) do
		-- Create the pattern button
		local button
		local index = #positionToSave + 1
		if v == "space" then
			button = WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName()..numSpacers, 
				parent, "SpacerTemplate")
			numSpacers = numSpacers + 1
		elseif v== "spaceHalf" then
			button = WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName()..numSpacers, 
				parent, "SpacerTemplate")
			numSpacers = numSpacers + 1
			button:SetWidth(24)
		else
			positionToSave[index] = WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName()..v, 
				parent, "PieceButtonTemplate")
			count = count + 1
			-- Easy reference
			button = positionToSave[index]
			button.tooltip = nameTable[count]
			button.selectedIndex = k
			-- Create the toggle
			local locationPart = string.lower(v)
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
			if v =="Ring" then
				initialX = initialX +  spacingForButtons
			end
			if v == "Neck" or v=="Ring" then
				
				button.ignoreStyle = true
			end
		end
		if lastButton then
			button:SetAnchor(LEFT , lastButton , RIGHT , 0, initialY)
		else
			button:SetAnchor(LEFT , parent , LEFT , 0, initialY)
		end
		lastButton = button
		--button:SetAnchor(CENTER , DolgubonSetCrafterWindowPatternInputPerson , CENTER , 
			--(-1)*60*((-1)^(index))*math.ceil(1 - 1/index), -160 +math.floor(index /2)*50 + math.floor(index/8)*50)

	end
end


-- Sets up the pattern buttons and places them all in a table
--(for the tables with info on patterns, see ConstantSetup.lua)
function DolgubonSetCrafter.setupPatternButtons()


	-- Table to hold all the pattern buttons
	DolgubonSetCrafter.patternButtons = {}
	DolgubonSetCrafter.armourTypes = {}

	setupPatternButtonOneTable(pieceNames 	,langStrings.pieceNames	,0,0 , DolgubonSetCrafter.patternButtons,DolgubonSetCrafterWindowPatternInputArmour )
	setupPatternButtonOneTable(jewelryNames ,langStrings.jewelryNames,0,0 , DolgubonSetCrafter.patternButtons,DolgubonSetCrafterWindowPatternInputJewelry )
	
	setupPatternButtonOneTable(weaponNames	,langStrings.weaponNames,0 ,0, DolgubonSetCrafter.patternButtons, DolgubonSetCrafterWindowPatternInputWeapons)
	setupPatternButtonOneTable(armourTypes	,langStrings.armourTypes,0 ,0, DolgubonSetCrafter.armourTypes, DolgubonSetCrafterWindowPatternInputArmourTypes)
	DolgubonSetCrafter.armourTypes[1]:toggle()

--	  -400 					,  0
-- -400-spacingForButtons*10	, 45
--  150					 	,  0

	debugSelections[#debugSelections+1] = function() DolgubonSetCrafter.patternButtons[1]:toggle() end
	local patternButtons = DolgubonSetCrafter.patternButtons
	-- Now, make functions which return what station, what styles to use, if it uses weight, and what traits to use
	
	setupPatternButtonFunctions(patternButtons)

	DolgubonSetCrafter.armourTypes.weight = 1
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
			DolgubonSetCrafter.armourTypes.weight = i
			self.toggleValue = true
			self:SetNormalTexture(self.onTexture)
			if onOverTexture then self:SetMouseOverTexture(self.onOverTexture) end
			setOtherArmourTypesToZero(i)
			if i == 3 then
				DolgubonSetCrafterWindowPatternInputArmourJerkin:SetHidden(false)
			else
				DolgubonSetCrafterWindowPatternInputArmourJerkin:toggleOff()
				DolgubonSetCrafterWindowPatternInputArmourJerkin:SetHidden(true)
			end

		end
	end
end

local out = DolgubonSetCrafter.out
--/script d(Dolgubons_Set_Crafter_Style:GetNamedChild( Dolgubons_Set_Crafter_Style:GetChild(1):GetName() ) )

function DolgubonSetCrafterWindowComboboxes:anchoruiElements()

	local vSpacing = 0
	local vPad = 5
	self.elements = self.elements or {}
	for i = 1, #self.elements do
		self.elements[i]:ClearAnchors()
	end
	local minLeftSize = 1000
	local minRightSize = 1000
	local lastControlRight = nil
	local lastControlLeft = nil
	for i = 1, #self.elements do
		self.elements[i]:ClearAnchors()
		if i %2 == 1 then -- LEFT SIDE
			if i>2 then

				self.elements[i]:SetAnchor(TOPLEFT , self.elements[i - 2], BOTTOMLEFT, 0,  vPad)
				self.elements[i]:SetAnchor(TOPRIGHT, self.elements[i - 2], BOTTOMRIGHT, 0,  vPad)
			else
				self.elements[i]:SetAnchor(LEFT, self, BOTTOMLEFT, 10,  vPad +  7)
				self.elements[i]:SetAnchor(RIGHT, self, BOTTOM, 0, vPad +  7)
			end
			if self.elements[i]:GetNamedChild("ComboBox") then
				self.elements[i]:GetNamedChild("ComboBox"):SetWidth(230)
			end
			if self.elements[i]:GetNamedChild("Name") then
				minLeftSize = math.min(self.elements[i]:GetNamedChild("Name"):GetTextWidth() + 230, minLeftSize)

			end
		else -- RIGHT SIDE
			if i > 2 then
				self.elements[i]:SetAnchor(TOPLEFT , self.elements[i - 2], BOTTOMLEFT, 0,  vPad)
				self.elements[i]:SetAnchor(TOPRIGHT, self.elements[i - 2], BOTTOMRIGHT, 0,vPad )
			else
				self.elements[i]:SetAnchor(RIGHT, self, BOTTOMRIGHT, -40,vPad + 7 )
				self.elements[i]:SetAnchor(LEFT, self, BOTTOM, 15, vPad  + 7)
			end
			if self.elements[i]:GetNamedChild("ComboBox") then
				self.elements[i]:GetNamedChild("ComboBox"):SetWidth(160)
			end
			if self.elements[i]:GetNamedChild("Name") then
				minRightSize = math.min(self.elements[i]:GetNamedChild("Name"):GetTextWidth() + 130, minRightSize)
			end
		end
		lastControl = self.elements[i]
	end

	DolgubonSetCrafterWindow.minWidth = ( DolgubonSetCrafterWindow.minWidth or 0) + minRightSize + minLeftSize
	self:SetDimensions(800,math.ceil(#self.elements/2)*vSpacing + 25)
	self.height = math.ceil(#self.elements/2)*vSpacing + 25
	DolgubonSetCrafterWindowLeftInteractionButtons:ClearAnchors()
	DolgubonSetCrafterWindowLeftInteractionButtons:SetAnchor(TOPLEFT, self.elements[#self.elements - 1], BOTTOMLEFT, 0,vPad)
	DolgubonSetCrafterWindowLeftInteractionButtons:SetAnchor(TOPRIGHT, self.elements[#self.elements], BOTTOMRIGHT, 0,vPad)

end

function DolgubonSetCrafterWindowComboboxes:adduiElement(newElement, position)

	-- create the elements table or grab the old one
	self.elements = self.elements or {}
	-- Add the new element to the elements table
	if position then
		table.insert(self.elements,  position, newElement)
	else
		table.insert(self.elements,  newElement)
	end
	

	-- Finally, set the anchors for all the elements
	
--(CENTER,  DolgubonSetCrafterWindowComboboxes,CENTER, x,y)
end


-- Creates one dropdown box using the passed information
local function makeDropdownSelections(comboBoxContainer, tableInfo , text , x, y, comboBoxLocation, selectionTypes, isArmourCombobox)

	if selectionTypes == "armourTrait" then isArmourCombobox = true elseif selectionTypes == "weaponTrait" then isArmourCombobox = false end
	local comboBox = comboBoxContainer:GetChild(comboBoxLocation)
	-- if location is 1 then get child number 2 and if location is 2 get child number 1
	-- It was a fun exercise to not have to write an if statement
	comboBoxContainer:GetChild((comboBoxLocation+2)%2+1):SetText(text..":")
	if not comboBox.m_comboBox then 
		comboBox.m_comboBox =comboBox.dropdown
		comboBox.dropdown.m_container:SetDimensions(200,30)
		comboBox.dropdown.m_dropdown:SetDimensions(200,370)
	end
	--Function called when an option is selected
	function comboBox:setSelected(comboBox, selectedInfo)
		if selectedInfo[1] ~= -1 then
			DolgubonSetCrafter.savedvars[selectionTypes] = selectedInfo[1]
		end
		selectedInfo[2] =zo_strformat("<<t:1>>",selectedInfo[2])
		comboBox.m_comboBox.selectedIndex = selectedInfo[1]
		comboBox.m_comboBox.selectedName = selectedInfo[2]
		comboBox.m_comboBox:HideDropdownInternal()
		comboBoxContainer.selected = selectedInfo

		comboBoxContainer.invalidSelection = function(weight, isAmour)
			return selectedInfo[1]==-1 

		end
	end
	-- We want to keep the original order of the stuff listed. However, the style and set boxes are sorted before anyway
	comboBox.m_comboBox:SetSortsItems(false) 
	-- Set the default entry
	comboBox.itemEntryDefault = ZO_ComboBox:CreateItemEntry(zo_strformat(langStrings.UIStrings.comboboxDefault,text), function() 
		comboBox:setSelected(comboBox, {-1,zo_strformat(langStrings.UIStrings.comboboxDefault ,text)})
			end )
	comboBox.m_comboBox:AddItem(comboBox.itemEntryDefault)
	comboBoxContainer.selectPrompt = zo_strformat(langStrings.UIStrings.selectPrompt,text)

	-- Select the first/default item
	function comboBoxContainer:SelectFirstItem()
		comboBox.m_comboBox:SelectItem(comboBox.itemEntryDefault) 
	end
	comboBoxContainer:SelectFirstItem()

	for i, value in pairs(tableInfo) do
		local itemEntry = ZO_ComboBox:CreateItemEntry(zo_strformat("<<t:1>>",tableInfo[i][2]), function() comboBox:setSelected(comboBox, tableInfo[i])end )
		
		comboBox.m_comboBox:AddItem(itemEntry)
		if i == 1 then
			-- Debug selection
			function comboBoxContainer:SelectDebug()
				comboBox.m_comboBox:SelectItem(itemEntry)
			end
			debugSelections[#debugSelections+1] = function() comboBoxContainer:SelectDebug() end
			function comboBoxContainer:SelectAutoFill()
				if self.name~="Style" and comboBoxContainer.invalidSelection(requestTable["Weight"]) and DolgubonSetCrafter:GetSettings().autofill then
					comboBox.m_comboBox:SelectItem(itemEntry)
				end
			end
			debugSelections[#debugSelections+1] = function() comboBoxContainer:SelectDebug() end

			autofillFunctions[#autofillFunctions + 1] = function() comboBoxContainer:SelectAutoFill() end
		end
		
		if tableInfo[i][1] == DolgubonSetCrafter.savedvars[selectionTypes] and DolgubonSetCrafter.savedvars.saveLastChoice then
			comboBox.m_comboBox:SelectItem(itemEntry)
		end
	end

	
	--set size + position
	comboBoxContainer:SetAnchor(CENTER,  DolgubonSetCrafterWindowComboboxes,CENTER, x,y)
	

	--make the selection
	comboBox.m_comboBox:SetSelectedItemFont("ZoFontGameMedium")
	comboBox.m_comboBox:SetDropdownFont("ZoFontGameMedium")
	DolgubonSetCrafterWindowComboboxes:adduiElement(comboBoxContainer)
end

-- Sets up the different combo boxes
function DolgubonSetCrafter.setupComboBoxes()
	--initial creation of blank combo boxes
	-- Note: Could be combined into a loop or something, but left like this for clarity
	DolgubonSetCrafter.ComboBox = {}

	DolgubonSetCrafter.ComboBox.Armour 		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Armour_Trait", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Weapon 		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Weapon_Trait", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Quality		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Quality", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Jewelry		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Jewelry_Trait", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Set			= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Set", DolgubonSetCrafterWindowComboboxes, "ScrollComboboxTemplate")
	DolgubonSetCrafter.ComboBox.Style 		= WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_Style", DolgubonSetCrafterWindowComboboxes, "ScrollComboboxTemplate")
	
	for k, v in pairs(DolgubonSetCrafter.ComboBox) do
		v.name = k
	end
	
	local UIStrings = langStrings.UIStrings
	--Three calls to make dropdown selections, as well as further setup the comboboxes.
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Style  	   	, DolgubonSetCrafter.styleNames   , UIStrings.style 		, -160, 80, 2, "style")
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Armour 		, DolgubonSetCrafter.armourTraits , UIStrings.armourTrait 	, -160, 120, 1, "armourTrait")
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Quality	   	, DolgubonSetCrafter.quality 	  , UIStrings.quality 		, 240 , 80, 1, "quality")
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Weapon 		, DolgubonSetCrafter.weaponTraits , UIStrings.weaponTrait 	, 240 , 120, 1, "weaponTrait")
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Set  	   	, DolgubonSetCrafter.setIndexes   , UIStrings.gearSet 		, 240, 40, 2, "set")
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.Jewelry	   	, DolgubonSetCrafter.jewelryTraits, UIStrings.jewelryTrait	, -160, 160, 1, "jewelryTraits")
	DolgubonSetCrafter.ComboBox.Armour.isTrait = true
	DolgubonSetCrafter.ComboBox.Weapon.isTrait = true
	DolgubonSetCrafter.ComboBox.Jewelry.isTrait = true
	--DolgubonSetCrafterWindowComboboxes:anchoruiElements()
end

function DolgubonSetCrafter:GetLevel()
	local level = DolgubonSetCrafterWindowInputInputBox:GetText()
	local isCP = not DolgubonSetCrafterWindowInputToggleChampion.toggleValue
	if level == "" then
		return nil, isCP
	end
	return tonumber(level), isCP
end

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
	createToggle( DolgubonSetCrafterWindowInputToggleChampion , [[esoui\art\treeicons\achievements_indexicon_champion_up.dds]] , [[esoui\art\treeicons\achievements_indexicon_champion_down.dds]], false)

	DolgubonSetCrafterWindowInputToggleChampion.onToggle = function(self, newState) 
		DolgubonSetCrafterWindowInputCPLabel:SetHidden(newState)
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

-- Create the scroll list for the queue
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
--TamrielTradeCentrePrice:GetPriceInfo

local function getPrice(itemLink)
	if MasterMerchant then
		local itemID = tonumber(string.match(itemLink, '|H.-:item:(.-):'))
		local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
		local price = MasterMerchant:toolTipStats(itemID, itemIndex, true, nil, false)['avgPrice']
		if price then
			return price
		else
			return GetItemLinkValue(itemLink)
		end 
	else
		return GetItemLinkValue(itemLink)
	end
end

local function round(price)
	price = math.floor( price * 100 + 0.5)
	price = price/100
	return price
end

local function updateCost()
	local cost = 0
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		local link = v["Name"]
		local price = round(getPrice(link))

		cost = cost + price * v["Amount"]
	end 
	DolgubonSetCrafterWindowRightCost:SetText("Total Cost: "..cost.." |t20:20:esoui/art/currency/currency_gold_64.dds|t")
end
-- Create the scroll list for the materials
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

	local originalRefresh = self.RefreshData
	self.RefreshData = function(...)
		
		originalRefresh(...)
		updateCost()
	end


	return self
	
end

local function formatAmountEntry(self, amountRequired, current)
	local text
	if current < amountRequired	 then
		amountRequired = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(amountRequired, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		current = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		text = "|cFFBFBF"..tostring(current).."|r/"..tostring(amountRequired)
	else
		amountRequired = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(amountRequired, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		current = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		text = tostring(current).."/"..tostring(amountRequired)
	end
	self:SetText(text)
	local width = self:GetTextWidth()
	
end

function MaterialScroll:SetupEntry(control, data)

	control.data = data
	control.isKnown = data[1]["Amount"]<= data[1]["Current"]
	for k , v in pairs(data[1]) do
		control[k] = GetControl(control, k)
		if control[k] then
			if k == "Amount" then
				formatAmountEntry(control[k], v, data[1]["Current"])
			else
				control[k]:SetText(v)
			end
		end
	end
	local BG = GetControl(control, "BG")
	
	if BG then
		BG:SetAnchorFill(control)
		--BG.nonRecolorable = false
		--local colour = BG.SetColor
		--BG.SetColor = function() end
		--BG.HideSetColor = colour
		if not control.isKnown then
			--BG:SetColor(1,0.5,0.5,0.2)
			BG:SetCenterColor(1, 0.5, 0.5, 0.2)
			BG:SetEdgeColor(0,0,0,0)
			
		else
			--BG:SetColor(0.5,0.8,1,0.2)
			BG:SetEdgeColor(0,0,0, 0)
			BG:SetCenterColor(0.5,0.5,0.5,0.05)

		end
	end
	ZO_SortFilterList.SetupRow(self, control, data)
end

function DolgubonSetCrafter.outputSingleMatLine(control)
	local text
	text = tostring(control.data[1]["Amount"]).." "
	text = text..control.data[1]["Name"]
	return text
end

outputTexts = {}
--@nighn_9, 38

local function OutputNextLine(eventCode,  channelType, fromName, text, isCustomerService, fromDisplayName)
	
	if fromDisplayName == GetDisplayName() or channelType == CHAT_CHANNEL_WHISPER_SENT then
		testActualOutput = text
		testAssume = outputTexts[1]
		if text == outputTexts[1] then
			table.remove(outputTexts, 1)
			if #outputTexts>0 then
				StartChatInput(outputTexts[1])
			else
				EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_CHAT_MESSAGE_CHANNEL)
			end
		else
		end
	end
end

function DolgubonSetCrafter.outputAllMats()
	local tempMatHolder = {}
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		tempMatHolder[#tempMatHolder + 1] = v
	end
	if #tempMatHolder == 0 then return end
	table.sort(tempMatHolder, function(a, b) return a["Amount"]>b["Amount"]end)
	
	outputTexts  = {}
	local text = "Requires: "
	
	for i = 1, #tempMatHolder do
		
		if i %4 ==1 and i > 1 then
			
			outputTexts[#outputTexts + 1] = text
			text = "And: "
		end
		if i>1 and not (i %4 ==1 and i>1) then
			text = text.." l "
		end
		text =text.. tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"]
	end
	outputTexts[#outputTexts + 1] = text
	StartChatInput(outputTexts[1])
	EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name,EVENT_CHAT_MESSAGE_CHANNEL, OutputNextLine)
end

local function MailNextLine(eventCode)
	local receiver = DolgubonSetCrafterWindowRightInputBox:GetText()
	local subject = mailOutputTexts[#mailOutputTexts][2]
	local body = mailOutputTexts[#mailOutputTexts][1]

	zo_callLater(function()d("Sending "..subject.." to "..receiver) SendMail(receiver, subject, body) end , 100)

	table.remove(mailOutputTexts)
	if #mailOutputTexts>0 then
		
	else
		EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_MAIL_SEND_SUCCESS)
		zo_callLater(CloseMailbox, 300)
	end


end

function DolgubonSetCrafter.mailAllMats()
	local tempMatHolder = {}
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		tempMatHolder[#tempMatHolder + 1] = v
	end
	if #tempMatHolder == 0 then d("No items required") return end
	table.sort(tempMatHolder, function(a, b) return a["Amount"]>b["Amount"]end)
	
	mailOutputTexts  = {}
	local text = "Your request will require:\n"
	
	for i = 1, #tempMatHolder do
		
		if i %9 ==1 and i > 1 then
			
			mailOutputTexts[#mailOutputTexts + 1] = {text.."(continued in next mail)", "Material Requirements ".. (#mailOutputTexts + 1)}
			text = "You will also require:\n"
		end

		text =text.. tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"].."\n"
	end
	mailOutputTexts[#mailOutputTexts + 1] = {text, "Material Requirements ".. (#mailOutputTexts + 1)}
	local receiver = DolgubonSetCrafterWindowRightInputBox:GetText()
	if #receiver < 3 then 
		out("Invalid name")
		return 
	end
	RequestOpenMailbox() -- required
	EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name,EVENT_MAIL_SEND_SUCCESS, MailNextLine)
	MailNextLine()
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
	if data[1].CraftRequestTable[7] ~= 7 then
		control.usesMimicStone = data[1].CraftRequestTable[6]
	end

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
	DolgubonSetCrafterWindowRightLabel:SetText 				(langStrings.UIStrings.materialScrollTitle)

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
	if GetCVar("language.2") == "fr" then
		mimicStones:GetNamedChild("Label"):SetText("Utiliser Pierre Cameleon")
	else
		mimicStones:GetNamedChild("Label"):SetText(GetString(SI_CRAFTING_CONFIRM_USE_UNIVERSAL_STYLE_ITEM_TITLE))
		
	end
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


	DolgubonSetCrafter.manager = DolgubonScroll:New(CraftingQueueScroll) -- check
	
	
	
	DolgubonSetCrafter.materialManager = MaterialScroll:New(DolgubonSetCrafterWindowMaterialList)
	

	--DolgubonSetCrafter.debugFunctions()
	DolgubonSetCrafter.initializeWindowPosition()
	DolgubonSetCrafterToggle:SetHidden(not DolgubonSetCrafter:GetSettings().showToggle )
	DolgubonSetCrafterWindowComboboxes:anchoruiElements(DolgubonSetCrafterWindowInput,1 )
	DolgubonSetCrafter.manager:RefreshData() -- Show the scroll
	DolgubonSetCrafter.materialManager:RefreshData()
	local includeFlags = { AUTO_COMPLETE_FLAG_ALL}
	ZO_AutoComplete:New(DolgubonSetCrafterWindowRightInputBox, includeFlags, {}, AUTO_COMPLETION_ONLINE_OR_OFFLINE, 5)

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
	DolgubonSetCrafterWindowInputInputBox:SetText("")
	DolgubonSetCrafterWindowMultiplierInputInputBox:SetText("1")
end

function DolgubonSetCrafter.onWindowMove(window)
	
	DolgubonSetCrafter.savedvars.xPos = window:GetLeft()
	DolgubonSetCrafter.savedvars.yPos = window:GetTop()
end

local function getDividerPosition(window, a)
	local DIVIDER_RATIO = 800/1050
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
	local LeftRightRatio =  800/1050
	local divider = window:GetNamedChild("divider")
	local left = window:GetNamedChild("Left")
	local right = window:GetNamedChild("Right")
	local newScale = window:GetWidth()/1050
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
	DolgubonSetCrafterWindow:SetDimensionConstraints(740, 470*(1 - (1 - newScale)/2))

	
	

end

local minXBeforeResize = 995
local minYBeforeResize = 460
function DolgubonSetCrafter.dynamicResize(window)
	a = a + 1
	-- Resize method 1
	getDividerPosition(window, a)
	DolgubonSetCrafter.manager:RefreshData() -- Show the scroll
	DolgubonSetCrafter.materialManager:RefreshData()
	
	-- Resize method 2
	local newScale = (1050 - window:GetWidth())*(-0.0008) + 1
	local scale = math.sqrt(window:GetWidth()/1050)
	SetWindowScale(window, scale)
	if true or window:GetWidth() > 1050 then return end
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
have never tried to add the same fragment to multiple scenes]]
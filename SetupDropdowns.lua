local langStrings

function DolgubonSetCrafterWindowComboboxes:anchoruiElements()

	local vSpacing = 0
	local vPad = 5
	self.elements = self.elements or {}
	for i = 1, #self.elements do
		self.elements[i]:ClearAnchors()
	end
	local minLeftSize = 1
	local minRightSize = 1
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
				-- minLeftSize = math.min(self.elements[i]:GetNamedChild("Name"):GetTextWidth() + 230, minLeftSize)

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
				self.elements[i]:GetNamedChild("ComboBox"):SetWidth(230)
			end
			if self.elements[i]:GetNamedChild("Name") then
				-- minRightSize = math.min(self.elements[i]:GetNamedChild("Name"):GetTextWidth() + 130, minRightSize)
			end
		end
		lastControl = self.elements[i]
	end

	-- DolgubonSetCrafterWindow.minWidth = ( DolgubonSetCrafterWindow.minWidth or 0) + minRightSize + minLeftSize
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
local function makeDropdownSelections(comboBoxContainer, tableInfo , text , x, y, comboBoxLocation, selectionTypes, noDefault)

	if selectionTypes == "armourTrait" then isArmourCombobox = true elseif selectionTypes == "weaponTrait" then isArmourCombobox = false end
	local comboBox = comboBoxContainer:GetChild(comboBoxLocation)
	-- if location is 1 then get child number 2 and if location is 2 get child number 1
	-- It was a fun exercise to not have to write an if statement
	-- comboBoxContainer:GetChild((comboBoxLocation+2)%2+1):SetText(text..":")
	comboBoxContainer:GetNamedChild("Name"):SetText(text..":")
	if not comboBox.m_comboBox then 
		comboBox.m_comboBox =comboBox.dropdown
		comboBox.dropdown.m_container:SetDimensions(225,30)
		comboBox.dropdown.m_dropdown:SetDimensions(225,370)
	end
	--Function called when an option is selected
	function comboBox:setSelected( selectedInfo)
		if selectedInfo[1] ~= -1 then
			DolgubonSetCrafter.savedvars[selectionTypes] = selectedInfo[1]
		end
		selectedInfo[2] =zo_strformat("<<t:1>>",selectedInfo[2])
		self.m_comboBox.selectedIndex = selectedInfo[1]
		self.m_comboBox.selectedName = selectedInfo[2]
		self.m_comboBox:HideDropdownInternal()
		comboBoxContainer.selected = selectedInfo

		comboBoxContainer.invalidSelection = function(weight, isAmour)
			return selectedInfo[1]==-1 

		end
	end

	-- We want to keep the original order of the stuff listed. However, the style and set boxes are sorted before anyway
	comboBox.m_comboBox:SetSortsItems(false) 
	-- Set the default entry
	if not noDefault then
		comboBox.itemEntryDefault = ZO_ComboBox:CreateItemEntry(zo_strformat(langStrings.UIStrings.comboboxDefault,text), function() 
			comboBox:setSelected( {-1,zo_strformat(langStrings.UIStrings.comboboxDefault ,text)})
				end )
		comboBox.m_comboBox:AddItem(comboBox.itemEntryDefault)
		comboBoxContainer.selectPrompt = zo_strformat(langStrings.UIStrings.selectPrompt,text)
		function comboBoxContainer:SelectFirstItem()
			comboBox.m_comboBox:SelectItem(comboBox.itemEntryDefault) 
		end
		comboBoxContainer:SelectFirstItem()
	end

	-- Select the first/default item
	
	comboBoxContainer.idSelectors = {}
	for i, value in pairs(tableInfo) do
		local itemEntry = ZO_ComboBox:CreateItemEntry(zo_strformat("<<t:1>>",tableInfo[i][2]), function() comboBox:setSelected( tableInfo[i])end )
		
		comboBox.m_comboBox:AddItem(itemEntry)
		if i == 1 then
			-- Debug selection

			function comboBoxContainer:SelectDebug()
				comboBox.m_comboBox:SelectItem(itemEntry)
			end
			DolgubonSetCrafter.debugSelections[#DolgubonSetCrafter.debugSelections+1] = function() comboBoxContainer:SelectDebug() end
			function comboBoxContainer:SelectAutoFill()
				if self.name~="Style" and comboBoxContainer.invalidSelection(requestTable["Weight"]) and DolgubonSetCrafter:GetSettings().autofill then
					comboBox.m_comboBox:SelectItem(itemEntry)
				end
			end
			DolgubonSetCrafter.debugSelections[#DolgubonSetCrafter.debugSelections+1] = function() comboBoxContainer:SelectDebug() end

			DolgubonSetCrafter.autofillFunctionTable [#DolgubonSetCrafter.autofillFunctionTable  + 1] = function() comboBoxContainer:SelectAutoFill() end
			if noDefault then
				comboBox.itemEntryDefault = itemEntry
				function comboBoxContainer:SelectFirstItem()
					comboBox.m_comboBox:SelectItem(comboBox.itemEntryDefault) 
				end
			end
			if (noDefault and  DolgubonSetCrafter.savedvars[selectionTypes]==nil) then
				comboBoxContainer:SelectFirstItem()
			end
		end
		if tableInfo[i][1] == DolgubonSetCrafter.savedvars[selectionTypes] and DolgubonSetCrafter.savedvars.saveLastChoice then
			comboBox.m_comboBox:SelectItem(itemEntry)
		end
		comboBoxContainer.idSelectors[tableInfo[i][1]] = itemEntry
	end

	--set size + position
	comboBoxContainer:SetAnchor(CENTER,  DolgubonSetCrafterWindowComboboxes,CENTER, x,y)

	comboBoxContainer.comboBox = comboBox
	comboBoxContainer.setSelected= function(self, selectId )
		self.comboBox:setSelected(self.comboBox, selectId)
	end
	function comboBoxContainer:setID(id)
		self.comboBox.m_comboBox:SelectItem(self.idSelectors[id])
	end
	--make the selection
	comboBox.m_comboBox:SetSelectedItemFont("ZoFontGameMedium")
	comboBox.m_comboBox:SetDropdownFont("ZoFontGameMedium")
	DolgubonSetCrafterWindowComboboxes:adduiElement(comboBoxContainer)
end

-- Sets up the different combo boxes
function DolgubonSetCrafter.setupComboBoxes()
	langStrings = DolgubonSetCrafter.localizedStrings
	--initial creation of blank combo boxes
	-- Note: Could be combined into a loop or something, but left like this for clarity
	DolgubonSetCrafter.ComboBox = {}

	DolgubonSetCrafter.ComboBox.ArmourEnchant = WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_ArmourEnchant", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.EnchantQuality = WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_EnchantQuality", DolgubonSetCrafterWindowComboboxes, "ComboboxTemplate")
	DolgubonSetCrafter.ComboBox.WeaponEnchant = WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_WeaponEnchant", DolgubonSetCrafterWindowComboboxes, "ScrollComboboxTemplate")
	DolgubonSetCrafter.ComboBox.JewelEnchant = WINDOW_MANAGER:CreateControlFromVirtual("Dolgubons_Set_Crafter_JewelEnchant", DolgubonSetCrafterWindowComboboxes, "ScrollComboboxTemplate")

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
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.WeaponEnchant, DolgubonSetCrafter.weaponEnchantments, UIStrings.weaponEnchant	, -160, 160, 2, "weaponEnchant", true)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.JewelEnchant, DolgubonSetCrafter.jewelryEnchantments, UIStrings.jewelryEnchant	, -160, 160, 2, "jewelEnchant", true)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.ArmourEnchant, DolgubonSetCrafter.armourEnchantments, UIStrings.armourEnchant	, -160, 160, 1, "armourEnchant", true)
	makeDropdownSelections( DolgubonSetCrafter.ComboBox.EnchantQuality, DolgubonSetCrafter.quality, UIStrings.enchantQuality	, -160, 160, 1, "enchantQuality")
	DolgubonSetCrafter.ComboBox.Armour.isTrait = true
	DolgubonSetCrafter.ComboBox.Weapon.isTrait = true
	DolgubonSetCrafter.ComboBox.Jewelry.isTrait = true
	DolgubonSetCrafter.ComboBox.Style.isStyle = true
	DolgubonSetCrafter.ComboBox.WeaponEnchant.isGlyph = true
	DolgubonSetCrafter.ComboBox.JewelEnchant.isGlyph = true
	DolgubonSetCrafter.ComboBox.ArmourEnchant.isGlyph = true
	DolgubonSetCrafter.ComboBox.EnchantQuality.isGlyphQuality = true
	--DolgubonSetCrafterWindowComboboxes:anchoruiElements()
end



--[[
Scenario 1:
Game crashes: Too bad. So Sad. You were gonna make it a second time anyway unless you cancel it. You won't make the glyph but eh
Scenario 2:
Glyph made: Well we won't requeue that glyph, but we will make the armour
Scenario 3:
Gear made: We won't requeue anything!
scenario 4:
Nothing made: No issues here


Save unique Item Id!!
On Login:
If it's found at the same place, great
If it's not found at the same place, search bags
If it's in inventory, great
If it's not in inventory, then do not remake item, only queue partially



]]
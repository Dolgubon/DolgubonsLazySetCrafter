
local createToggle = DolgubonSetCrafter.createToggle

local pieceNames = 
{
	"spaceHalf","Chest","Feet","Hands","Head","Legs","Shoulders","Belt","Jerkin", "space"
}

local jewelryNames =
{
	"Ring", "Ring", "Neck", "space", "space"
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
local langStrings
 

local spacingForButtons = 40
DolgubonSetCrafter.isMurkmure = true
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
	return weight, DolgubonSetCrafter.armourTypes[4 - weight].tooltip
end


local function setupPatternButtonFunctions(patternButtons)
	for i = 1, 8 do -- Armour, made to fit
		patternButtons[i].GetStation = function(self,weightOverride)
		local weight = weightOverride or DolgubonSetCrafter:GetWeight()
			if weight == ARMORTYPE_HEAVY then 
				return CRAFTING_TYPE_BLACKSMITHING 
			else
				return CRAFTING_TYPE_CLOTHIER
			end
		end
		patternButtons[i].UseStyle = function() return true end
		patternButtons[i].TraitsToUse = function()return DolgubonSetCrafter.ComboBox.Armour, DolgubonSetCrafter.ComboBox.ArmourEnchant end
		patternButtons[i].HaveWeights = function() return true end
		patternButtons[i].GetPattern = function(self, weightOverride)

			local weight = weightOverride or DolgubonSetCrafter:GetWeight()

			if weight ~=ARMORTYPE_LIGHT and i == 8 then return 0 end
			
			if weight == ARMORTYPE_HEAVY then
				return i + 7
			elseif weight == ARMORTYPE_MEDIUM then
				return i + 8
			else
				if i == 8 then return 2 end
				if i == 1 then return 1 end
				return i + 1
			end

		end
	end

	for i = 9, 11 do -- ring + neck
		patternButtons[i].GetStation = function() return CRAFTING_TYPE_JEWELRYCRAFTING end
		patternButtons[i].UseStyle = function() return false end
		patternButtons[i].TraitsToUse = function() return DolgubonSetCrafter.ComboBox.Jewelry, DolgubonSetCrafter.ComboBox.JewelEnchant end
		patternButtons[i].HaveWeights = function() return false end
		if i == 11 then
			patternButtons[i].GetPattern = function() return 2 end
		else
			patternButtons[i].GetPattern = function() return 1 end
		end
	end
	for i = 12, 18 do -- blacksmithing weapons
		patternButtons[i].GetStation = function() return CRAFTING_TYPE_BLACKSMITHING end
		patternButtons[i].UseStyle = function() return true end
		patternButtons[i].TraitsToUse = function() return DolgubonSetCrafter.ComboBox.Weapon, DolgubonSetCrafter.ComboBox.WeaponEnchant end
		patternButtons[i].HaveWeights = function() return false end
		patternButtons[i].GetPattern = function() return i - 11 end
	end
	for i = 19, 23 do -- woodworking weapons
		patternButtons[i].GetStation = function() return CRAFTING_TYPE_WOODWORKING end
		patternButtons[i].UseStyle = function() return true end
		patternButtons[i].TraitsToUse = function() return DolgubonSetCrafter.ComboBox.Weapon, DolgubonSetCrafter.ComboBox.WeaponEnchant end
		patternButtons[i].HaveWeights = function() return false end
		patternButtons[i].GetPattern = function() if i == 19 then return 1 else return i - 17 end end
	end
	local i = 24 -- shield
	patternButtons[i].GetStation = function() return CRAFTING_TYPE_WOODWORKING end
	patternButtons[i].UseStyle = function() return true end
	patternButtons[i].TraitsToUse = function()return DolgubonSetCrafter.ComboBox.Armour, DolgubonSetCrafter.ComboBox.ArmourEnchant end
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
			positionToSave[index] = WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName()..v..count, 
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
	langStrings = DolgubonSetCrafter.localizedStrings

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

	DolgubonSetCrafter.debugSelections [#DolgubonSetCrafter.debugSelections +1] = function() DolgubonSetCrafter.patternButtons[1]:toggle() end
	local patternButtons = DolgubonSetCrafter.patternButtons
	-- Now, make functions which return what station, what styles to use, if it uses weight, and what traits to use
	
	setupPatternButtonFunctions(patternButtons)

	DolgubonSetCrafter.armourTypes.weight = ARMORTYPE_HEAVY
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
			DolgubonSetCrafter.armourTypes.weight = 4 - i
			self.toggleValue = true
			self:SetNormalTexture(self.onTexture)
			if onOverTexture then self:SetMouseOverTexture(self.onOverTexture) end
			setOtherArmourTypesToZero(i)
			if i == 3 then
				DolgubonSetCrafterWindowPatternInputArmourJerkin7:SetHidden(false)
			else
				DolgubonSetCrafterWindowPatternInputArmourJerkin7:toggleOff()
				DolgubonSetCrafterWindowPatternInputArmourJerkin7:SetHidden(true)
			end

		end
	end
end
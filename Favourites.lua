-- What kind of structure for the save data?

--[[
savedVars = 
{
	["favourites"] = {
		[1] = 
		{
			["set"] = {name = Seducer, id = 1},
			quality = {},
			weapontrait ={},
			armourtrait ={},
			jewelrytrait={},
			style={},
			level={name = "CP150", isCP = true, lvl = 150},
			selected = {{shield, 14}, {chest, 1}, {dagger, 8} }
			weight = {name = heavy, id = 1}
			name = "Seducer Half Set Example" -- example default: CP150 Seducer -- will show in favourites list

		},
		[2] =
		{
	
		}, etc.
	}

}
]]

local function getEmptyFavourite()
return 
{
	set = {},
	quality = {},
	weaponTrait = {},
	armourTrait = {},
	jewelryTrait = {},
	style = {},
	level = {},
	selectedPatterns = {},
	weight = {},
	name = "",
	type = "Selection"
}
end

-- We're not using self so that we don't run into issues with the saved variables
local function addComboBoxValueToFavourite(faveTable, location,combo)
	if not combo.invalidSelection() then
		faveTable[location] = {["name"] = combo.selected[2], ["id"] = combo.selected[1]}
	end
end

local function addFavourite()
-- adds current selection as a favourite
	local faveTable = getEmptyFavourite()
	local patternButtonSelected = false
	for i = 1, #DolgubonSetCrafter.patternButtons do
		--d(DolgubonSetCrafter.patternButtons[i].tooltip..DolgubonSetCrafter.patternButtons[i].selectedIndex)
		if DolgubonSetCrafter.patternButtons[i].toggleValue then
			patternButtonSelected = true
			table.insert(faveTable.selectedPatterns, {name = DolgubonSetCrafter.patternButtons[i].tooltip, id = i})
		end
	end

	local comboBoxes = DolgubonSetCrafter.ComboBox
	addComboBoxValueToFavourite(faveTable, "set", comboBoxes.Set)
	addComboBoxValueToFavourite(faveTable, "quality", comboBoxes.Quality)
	addComboBoxValueToFavourite(faveTable, "weaponTrait", comboBoxes.Weapon)
	addComboBoxValueToFavourite(faveTable, "armourTrait", comboBoxes.Armour)
	addComboBoxValueToFavourite(faveTable, "jewelryTrait", comboBoxes.Jewelry)
	addComboBoxValueToFavourite(faveTable, "style", comboBoxes.Style)
	addComboBoxValueToFavourite(faveTable, "armourEnchant", comboBoxes.ArmourEnchant)
	addComboBoxValueToFavourite(faveTable, "enchantQuality", comboBoxes.EnchantQuality)
	addComboBoxValueToFavourite(faveTable, "weaponEnchant", comboBoxes.WeaponEnchant)
	addComboBoxValueToFavourite(faveTable, "jewelEnchant", comboBoxes.JewelEnchant )

	local level, isChampion = DolgubonSetCrafter:GetLevel()
	if level ~= "" and level then
		if isChampion then 
			faveTable.level = {name = "CP"..level , isChampion = isChampion, lvl = level}
		else
			faveTable.level = {name = level, isChampion = isChampion, lvl = level}
		end
		faveTable.name = faveTable.level.name.." "..faveTable.set.name
	else
		faveTable.level = {name = "", isChampion = false, lvl = nil}
		faveTable.name = faveTable.set.name
	end

	
	local weightId = DolgubonSetCrafter:GetWeight()
	if weightId == 1 then
		weightId = 3
	elseif weightId == 3 then
		weightId = 1
	end
	faveTable.weight = {name = DolgubonSetCrafter.armourTypes[weightId].tooltip, id = weightId}
	faveTable.id = GetTimeStamp() -- Will get a unique ID based on time. 

	table.insert(DolgubonSetCrafter.savedvars.faves, faveTable)
	DolgubonSetCrafter.FavouriteScroll:RefreshData()
	
end
DolgubonSetCrafter.addFavourite = addFavourite

local function addFavouriteQueue()
	local faveTable =
	{
		type = "Queue",
	}
	faveTable.name = "Queue: "..DolgubonSetCrafter.countTotalQueuedItems().." items"
	faveTable.queue = ZO_DeepTableCopy(DolgubonSetCrafter.savedvars.queue)
	table.insert(DolgubonSetCrafter.savedvars.faves, faveTable)
	DolgubonSetCrafter.FavouriteScroll:RefreshData()
end

DolgubonSetCrafter.addFavouriteQueue = addFavouriteQueue

local function loadSelectionFavourite(selectedFavourite)
		if #selectedFavourite.selectedPatterns>0 then
		for i = 1, #DolgubonSetCrafter.patternButtons do
			DolgubonSetCrafter.patternButtons[i]:toggleOff()
		end
		for k, v in pairs(selectedFavourite.selectedPatterns) do
			DolgubonSetCrafter.patternButtons[v.id]:toggleOn()
		end
	end

	local comboBoxes = DolgubonSetCrafter.ComboBox
	comboBoxes.Set:setID(selectedFavourite.set.id)
	comboBoxes.Quality:setID(selectedFavourite.quality.id)
	comboBoxes.Weapon:setID(selectedFavourite.weaponTrait.id)
	comboBoxes.Armour:setID(selectedFavourite.armourTrait.id)
	comboBoxes.Jewelry:setID(selectedFavourite.jewelryTrait.id)
	comboBoxes.Style:setID(selectedFavourite.style.id)
	comboBoxes.ArmourEnchant:setID(selectedFavourite.armourEnchant.id)
	comboBoxes.EnchantQuality:setID(selectedFavourite.enchantQuality.id)
	comboBoxes.WeaponEnchant:setID(selectedFavourite.weaponEnchant.id)
	comboBoxes.JewelEnchant :setID(selectedFavourite.jewelEnchant.id)
	DolgubonSetCrafter.CPToggle:setState(selectedFavourite.level.isChampion)
	DolgubonSetCrafter.levelInput:SetText(selectedFavourite.level.lvl)
	DolgubonSetCrafter.armourTypes[selectedFavourite.weight.id]:toggleOn()
end

local function loadRecipeQueueItem(queueInfo)
	d(queueInfo)
	DolgubonSetCrafter.addFurnitureByLink(queueInfo.Link, queueInfo.Quantity[1])
end

local function loadQueueFavourite(selectedFavourite, useCurrentLevel, useCurrentQuality, useCurrentSet, useCurrentStyle)
	if useCurrentLevel then
		d("LOADING Set Crafter selection: '"..selectedFavourite.name.."' with currently selected level")
	else
		d("LOADING Set Crafter selection: '"..selectedFavourite.name.."' with saved level")
	end
	
	for k, v in pairs(selectedFavourite.queue) do
		if v.isRecipe then
			loadRecipeQueueItem(v)
		else
			local copy = ZO_DeepTableCopy(v)
			copy["CraftRequestTable"][11] = DolgubonSetCrafter.savedvars.counter
			copy["Reference"] = DolgubonSetCrafter.savedvars.counter
			local returnedTable
			if useCurrentLevel then
				local level, isCP = DolgubonSetCrafter:GetLevel()
				local levelString = level
				if isCP then
					levelString = "CP "..levelString
				end
				-- re-generate level stuff
				copy["Level"] = {
					level, levelString, isCP
				}
				copy["CraftRequestTable"][2] = isCP
				copy["CraftRequestTable"][3] = level
				local r = copy["CraftRequestTable"]

				returnedTable = DolgubonSetCrafter.LazyCrafter:CraftSmithingItemByLevel(r[1], r[2], r[3],r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], nil, nil, nil, r[15])

				copy["Link"] = DolgubonSetCrafter.LazyCrafter.getItemLinkFromParticulars( returnedTable.setIndex,returnedTable.trait ,returnedTable.pattern ,returnedTable.station ,level, 
				isCP,returnedTable.quality,returnedTable.style, returnedTable.potencyItemId , returnedTable.essenceItemId, returnedTable.aspectItemId)
				
				if r[12] and r[13] and r[14] then -- If these are nil then there's no glyph
					local enchantLevel = LibLazyCrafting.closestGlyphLevel(isCP, level)
					enchantRequestTable = DolgubonSetCrafter.LazyCrafter:CraftEnchantingGlyphByAttributes(isCP, enchantLevel, 
					copy["Enchant"][1], copy["EnchantQuality"] , 
					DolgubonSetCrafter:GetAutocraft(), returnedTable["Reference"], returnedTable)
					r[12] = enchantRequestTable.potencyItemID
					r[13] = enchantRequestTable.essenceItemID
					r[14] = enchantRequestTable.aspectItemID
				end

			else
				local r = copy["CraftRequestTable"]
				returnedTable = DolgubonSetCrafter.LazyCrafter:CraftSmithingItemByLevel(r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15])
				-- returnedTable = DolgubonSetCrafter.LazyCrafter:CraftSmithingItemByLevel(unpack(copy["CraftRequestTable"]))
			end
			DolgubonSetCrafter.savedvars.counter = DolgubonSetCrafter.savedvars.counter + 1
			
			DolgubonSetCrafter.addRequirements(returnedTable, true)

			if pcall(function()DolgubonSetCrafter.applyValidityFunctions(v)end) then else d("Request could not be displayed. However, you should still be able to craft it.") end
			table.insert(DolgubonSetCrafter.savedvars.queue, copy)
		end
	end
	DolgubonSetCrafter.LazyCrafter:SetAllAutoCraft(DolgubonSetCrafter.savedvars.autoCraft)
	DolgubonSetCrafter.updateList()
end

local function loadFavourite(selectedFavourite)
	-- Load the favourite selection with that Id
	
	if not selectedFavourite then d("error no favourite table passed") return end
	if selectedFavourite.type == "Selection" then
		d("LOADING Set Crafter selection: '"..selectedFavourite.name.."'")
		loadSelectionFavourite(selectedFavourite)
	elseif selectedFavourite.type == "Queue" then
		ClearMenu()
		AddMenuItem(DolgubonSetCrafter.localizedStrings.UIStrings.loadQueueAsIs, function()loadQueueFavourite(selectedFavourite, false) end )
		AddMenuItem(DolgubonSetCrafter.localizedStrings.UIStrings.loadQueueCurrentLevel,  function()loadQueueFavourite(selectedFavourite, true) end )
		ShowMenu(dscont) -->
		-- loadQueueFavourite(selectedFavourite)
	else -- default for old favourites
		loadSelectionFavourite(selectedFavourite)
	end
end

DolgubonSetCrafter.loadFavourite = loadFavourite

local function deleteFavourite(favouriteTable)
	-- Delete a favourite
	for k, v in pairs(DolgubonSetCrafter.savedvars.faves) do
		if favouriteTable == v then
			table.remove(DolgubonSetCrafter.savedvars.faves, k)
		end
	end
	DolgubonSetCrafter.FavouriteScroll:RefreshData()
end
DolgubonSetCrafter.deleteFavourite = deleteFavourite

local function renameFavourite(favouriteTable, newName)
	-- Rename a favourite
	favouriteTable.name = newName
	DolgubonSetCrafter.FavouriteScroll:RefreshData()
end

DolgubonSetCrafter.renameFavourite = renameFavourite

function DolgubonSetCrafter.clearFavourites()
	DolgubonSetCrafter.savedvars.faves = {}
end
--ZO_CachedStrFormat("<<C:1>>", materialName
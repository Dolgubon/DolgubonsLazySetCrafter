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

	local level, isChampion = DolgubonSetCrafter:GetLevel()
	if level ~= "" then
		if not isCP then 
			faveTable.level = {name = "CP"..level , isChampion = isCP, lvl = level}
		else
			faveTable.level = {name = level, isChampion = isCP, lvl = level}
		end
	end

	faveTable.name = faveTable.level.name.." "..faveTable.set.name
	local weightId = DolgubonSetCrafter.armourTypes.weight

	faveTable.weight = {name = DolgubonSetCrafter.armourTypes[weightId].tooltip, id = weightId}

	faveTable.id = GetTimeStamp() -- Will get a unique ID based on time. 

	DolgubonSetCrafter.savedvars.faves[faveTable.id] = faveTable
	
end
DolgubonSetCrafter.addFavourite = addFavourite

local function loadFavourite(favouriteId)
	-- Load the favourite selection with that Id

	local selectedFavourite = DolgubonSetCrafter.savedvars.faves[favouriteId]
	if not selectedFavourite then d("error no fave here") return end

	for k, v in pairs(selectedFavourite.selectedPatterns) do
		DolgubonSetCrafter.patternButtons[v.id]:toggleOn()
	end

	local comboBoxes = DolgubonSetCrafter.ComboBox
	comboBoxes.Set:setID(selectedFavourite.set.id)
	comboBoxes.Quality:setID(selectedFavourite.quality.id)
	comboBoxes.Weapon:setID(selectedFavourite.weaponTrait.id)
	comboBoxes.Armour:setID(selectedFavourite.armourTrait.id)
	comboBoxes.Jewelry:setID(selectedFavourite.jewelryTrait.id)
	comboBoxes.Style:setID(selectedFavourite.style.id)
	DolgubonSetCrafter.CPToggle:setState(selectedFavourite.level.isCP)
	DolgubonSetCrafter.levelInput:SetText(selectedFavourite.level.lvl)
	DolgubonSetCrafter.armourTypes[selectedFavourite.weight.id]:toggleOn()

end

DolgubonSetCrafter.loadFavourite = loadFavourite

local function deleteFavourite(favouriteId)
	-- Delete a favourite
	DolgubonSetCrafter.savedvars.faves[favouriteId] = nil
end
DolgubonSetCrafter.deleteFavourite = deleteFavourite

local function renameFavourite(favouriteId, newName)
	-- Rename a favourite
	DolgubonSetCrafter.savedvars.faves[favouriteId].name = newName
end

DolgubonSetCrafter.renameFavourite = renameFavourite

function DolgubonSetCrafter.clearFavourites()
	DolgubonSetCrafter.savedvars.faves = {}
end

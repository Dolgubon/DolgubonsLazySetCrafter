-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
--local original = d local function d() original(pcall(function() error("There's a d() at this line!") end )) end

function determineLine()
	local a, b  = pcall( function() local a = nil a = a+ 1 end) return b,  tonumber(string.match (b, "^%D*%d+%D*%d+%D*%d+%D*%d+%D*(%d+)" ))
end

local originalD = d
local function d(...)
	if GetDisplayName()=="@Dolgubon" then 
		originalD(...)
	end
end
DolgubonSetCrafter = DolgubonSetCrafter or {}

local queue

local craftedItems = {}
local function removeFromScroll()
end

local LazyCrafter

local LibLazyCrafting = LibStub:GetLibrary("LibLazyCrafting")
local out = DolgubonSetCrafter.out

local validityFunctions 

local shortVersions =
{
	{"Whitestrake's Retribution","Whitestrakes"},
	{"Daggerfall Covenant","Daggerfall"},
	{"Armor of the Seducer","Seducer"},
	{"Night Mother's Gaze","Night Mother's"},
	{"Twilight's Embrace", "Twilight's"},
	{"Alliance de Daguefilante", "Daguefilante"},
	{"Ordonnateur Militant","Ordonnateur"},
	{"Pacte de Cœurébène","Cœurébène"},

}

local achievements = {
	[ITEMSTYLE_AREA_DWEMER] =  1144, --Dwemer
	[ITEMSTYLE_GLASS] =  1319, --Glass
	[ITEMSTYLE_AREA_XIVKYN] =  1181, --Xivkyn
	[ITEMSTYLE_AREA_ANCIENT_ORC] =  1341, --Ancient Orc
	[ITEMSTYLE_AREA_AKAVIRI] =  1318, --Akaviri
	[ITEMSTYLE_UNDAUNTED] =  1348, --Mercenary
	[ITEMSTYLE_DEITY_MALACATH] =  1412, --Malacath
	[ITEMSTYLE_DEITY_TRINIMAC] =  1411, --Trinimac
	[ITEMSTYLE_ORG_OUTLAW] =  1417, --Outlaw
	[ITEMSTYLE_ALLIANCE_EBONHEART] =  1414, --Ebonheart
	[ITEMSTYLE_ALLIANCE_ALDMERI] = 1415, --Aldmeri
	[ITEMSTYLE_ALLIANCE_DAGGERFALL] =  1416, --Daggerfall
	[ITEMSTYLE_ORG_ABAHS_WATCH] =  1422, --Abah's Watch
	[ITEMSTYLE_ORG_THIEVES_GUILD] =  1423, --ThievesGuild
	[ITEMSTYLE_ORG_ASSASSINS] =  1424, --Assassins League
	[ITEMSTYLE_ENEMY_DROMOTHRA] =  1659, --DroMathra
	[ITEMSTYLE_DEITY_AKATOSH] =  1660, --Akatosh
	[ITEMSTYLE_ORG_DARK_BROTHERHOOD] =  1661, --Dark Brotherhood
	[ITEMSTYLE_ENEMY_MINOTAUR] =  1662, --Minotaur
	[ITEMSTYLE_RAIDS_CRAGLORN] =  1714, --Craglorn
	[ITEMSTYLE_ENEMY_DRAUGR] =  1715, --Draugr
	[ITEMSTYLE_AREA_YOKUDAN] =  1713, --Yokudan
	[ITEMSTYLE_HOLIDAY_HOLLOWJACK] =  1545, --Hallowjack
	[ITEMSTYLE_HOLIDAY_SKINCHANGER] =  1676, --Skinchanger
	[ITEMSTYLE_EBONY] =  1798, --Ebony
	[ITEMSTYLE_AREA_RA_GADA] =  1797, --Ra Gada
	[ITEMSTYLE_ENEMY_SILKEN_RING] = 1796, --Silken Ring
	[ITEMSTYLE_ENEMY_MAZZATUN] = 1795, --Mazzatum
	[ITEMSTYLE_ORG_MORAG_TONG] = 1933, --Morag Tong
	[ITEMSTYLE_ORG_ORDINATOR] = 1935, --Ordinator
	[ITEMSTYLE_ORG_BUOYANT_ARMIGER] = 1934, --Buoyant Armiger
	[ITEMSTYLE_AREA_ASHLANDER] = 1932, --Ashlander
	[ITEMSTYLE_ORG_REDORAN] = 2022, --Redoran
	[ITEMSTYLE_ORG_HLAALU] = 2021, --Hlaalu
	[ITEMSTYLE_ORG_TELVANNI] = 2023, --Telvanni
	[61] = 2098, --Bloodforge
	[62] = 2097, --Dreadhorn
	[65] = 2044, --Apostle
	[66] = 2045, --Ebonshadow
}
----------------------------------------------------
-- HELPER FUNCTIONS

local function StripColorAndWhitespace(text)

	text = string.gsub(text, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]", "")
	text = string.gsub(text, "|r", "")
	return text
end

local function shortenNames(requestTable)

	for k,v in pairs(requestTable) do
		if type(v)=="table" then
			for i = 1, #shortVersions do

				v[2] = StripColorAndWhitespace(v[2])

				if shortVersions[i][1] == v[2] then

					v[2] = shortVersions[i][2]
				end
			end
		end
	end
end

function getNumTraitsKnown(station, pattern, trait) -- and if the trait is known
	local count = 0
	local traitKnown =false
	for i =1 ,9 do 
		local traitIndex,_,known = GetSmithingResearchLineTraitInfo(station, pattern, i)
		
		if known then
			count = count + 1
		end
		
		if traitIndex == trait then
			_,_, traitKnown = GetSmithingResearchLineTraitInfo(station, pattern, i)
			
		end
	end
	return count, traitKnown
end

function isTraitKnown(station, pattern, trait, setIndex) -- more of a router than anything. Calls getNumTraitsKnown to do the work


	trait = trait - 1
	local known, number
	if station ==CRAFTING_TYPE_WOODWORKING and pattern>1 then
		if pattern == 2 then
			number, known = getNumTraitsKnown(station, 6, trait)
		else
			number, known = getNumTraitsKnown(station, pattern -1, trait)
		end
	else
		number, known = getNumTraitsKnown(station, pattern, trait)
	end
	if trait == 0 then known = true end
	--d("Is trait known:"..tostring(known)..tostring(trait).. "with "..tostring(number).." traits known")
	return known, number>= GetSetIndexes()[setIndex][3]
end

function isStyleKnownForPattern(styleIndex, station, pattern)
	local map = -- The index of the achievement criterion to check for each pattern
	{
		[1] = {1, 10, 14, 1, 10, 14, 6, 5,3, 7, 8, 9, 12, 2},
		[2] = {5, 5,3, 7, 8, 9, 12, 2, 5,3, 7, 8, 9, 12, 2},
		[6] = {4, 13, 13, 13, 13, 11},
	}
	if IsSmithingStyleKnown(styleIndex) then return true end
	if not achievements[styleIndex] then return false end
	local _, isKnown = GetAchievementCriterion( achievements[styleIndex], map[station][pattern])
	return isKnown == 1
end

validityFunctions = --stuff that's not here will automatically recieve a value of true.
{ -- Second value is the required parameters from the craftrequesttable needed to determine ability to craft
	["Trait"] = {function(...) local a = isTraitKnown(...) return a end , {7, 1,5, 8}},
	["Set"] = {function(...)local _,a = isTraitKnown(...) return a end , {7,1,5,8}},
	["Style"] = {isStyleKnownForPattern , {4, 7, 1}},
}


-- uses the info in validityFunctions to recheck and see if attributes are an impediment to crafting.
local function applyValidityFunctions(requestTable) 
	for attribute, table in pairs(validityFunctions) do
		local params = {}

		for i = 1, #table[2]  do

			params[#params + 1] = requestTable["CraftRequestTable"][table[2][i]]

		end
		--d("one application for: "..attribute)
		requestTable[attribute][3] = table[1](unpack(params) )

	end
end

DolgubonSetCrafter.applyValidityFunctions = applyValidityFunctions


-- Finds the material index based on the level
local function findMatIndex(level, champion)

	local index = 1

	if champion then
		index = 26
		index = index + math.floor(level/10)
	else
		index = 0
		if level<3 then
			index = 1
		else
			index = index + math.floor(level/2)
		end
	end
	return index

end

local function getPatternIndex(patternButton,weight)
	--d(patternButton.selectedIndex)
	local candidate = patternButton.selectedIndex
	if weight == nil then
		-- It is a weapon
		if patternButton.selectedIndex==8 then
			-- it is a bow
			return 1, CRAFTING_TYPE_WOODWORKING
		elseif patternButton.selectedIndex==13 then
			-- it is a shield
			return 2, CRAFTING_TYPE_WOODWORKING
		elseif patternButton.selectedIndex<8 then
			-- It is metal
			return patternButton.selectedIndex , CRAFTING_TYPE_BLACKSMITHING
		else
			-- it is a staff
			return patternButton.selectedIndex - 6, CRAFTING_TYPE_WOODWORKING
			
		end
	else
		-- It is armour
		if weight == 1 then
			-- It is heavy armour
			return patternButton.selectedIndex + 7, CRAFTING_TYPE_BLACKSMITHING
		elseif weight == 2 then
			-- It is medium armour
			return patternButton.selectedIndex + 8, CRAFTING_TYPE_CLOTHIER
		else
			-- It is light armour
			if patternButton.selectedIndex==8 then
				return 2, CRAFTING_TYPE_CLOTHIER
			elseif patternButton.selectedIndex==1 then
				return 1, CRAFTING_TYPE_CLOTHIER
			else
				return patternButton.selectedIndex + 1, CRAFTING_TYPE_CLOTHIER
			end
		end

	end
end


local function addPatternToQueue(patternButton,i)
	local function shallowTwoItemCopy(t)
		return {t[1],t[2]}
	end
	local comboBoxes = DolgubonSetCrafter.ComboBox
	local requestTable = {}
	
	local pattern, station  = 0, 0
	local trait = 0

	if i<9 then
		for i = 1, 3 do 

			if DolgubonSetCrafter.armourTypes[i].toggleValue then

				
				requestTable["Weight"] = {i,DolgubonSetCrafter.armourTypes[i].tooltip}

				pattern, station = getPatternIndex(patternButton,i)
			end

		end
		requestTable["Trait"] = shallowTwoItemCopy(comboBoxes.Armour.selected)
		trait = comboBoxes.Armour.selected[1]
	elseif i== 21 then
		requestTable["Weight"] = {nil, ""}
		requestTable["Trait"] = shallowTwoItemCopy(comboBoxes.Armour.selected)
		pattern, station = getPatternIndex(patternButton)
		trait = comboBoxes.Armour.selected[1]	
	else
		requestTable["Weight"] = {nil, ""}
		requestTable["Trait"] = shallowTwoItemCopy(comboBoxes.Weapon.selected)
		pattern, station = getPatternIndex(patternButton)
		trait =comboBoxes.Weapon.selected[1]
	end
	requestTable["Pattern"] = {pattern,patternButton.tooltip}
	requestTable["Level"] = {tonumber(DolgubonSetCrafterWindowInputBox:GetText()),DolgubonSetCrafterWindowInputBox:GetText()}
	if requestTable["Level"][2]=="" then requestTable["Level"][1]=nil out(DolgubonSetCrafterWindowInputBox.selectPrompt) return end
	for k, combobox in pairs(comboBoxes) do
		if combobox.invalidSelection(requestTable["Weight"][2]) and not DolgubonSetCrafter.savedVars.autofill then
			out(combobox.selectPrompt)
			return
		end
	end

	
	local isCP = not DolgubonSetCrafterWindowInputToggleChampion.toggleValue
	requestTable["Style"] 		= shallowTwoItemCopy(comboBoxes.Style.selected)
	
	local styleIndex 			= comboBoxes.Style.selected[1]
	requestTable["Set"]			= shallowTwoItemCopy(comboBoxes.Set.selected)
	

	local setIndex 				= comboBoxes.Set.selected[1]
	requestTable["Quality"]		= shallowTwoItemCopy(comboBoxes.Quality.selected)
	
	local quality 				= comboBoxes.Quality.selected[1]
	requestTable["Reference"]	= DolgubonSetCrafter.savedVars.counter
	DolgubonSetCrafter.savedVars.counter = DolgubonSetCrafter.savedVars.counter + 1
	-- Some names are just so long, we need to shorten it
	shortenNames(requestTable)

	if pattern and isCP ~= nil and requestTable["Level"][1] and styleIndex and trait and station and setIndex and quality and requestTable["Reference"] then
		local CraftRequestTable = {pattern, isCP,tonumber(requestTable["Level"][1]),styleIndex,trait, false, station,  setIndex, quality, true, requestTable["Reference"]}
		LazyCrafter:CraftSmithingItemByLevel(unpack(CraftRequestTable))
		
		--LLC_CraftSmithingItemByLevel(self, patternIndex, isCP , level, styleIndex, traitIndex, useUniversalStyleItem, stationOverride, setIndex, quality, autocraft)
		if not DolgubonSetCrafterWindowInputToggleChampion.toggleValue then
			requestTable["Level"][2] = "CP"..requestTable["Level"][2]
		end
		requestTable["CraftRequestTable"] = CraftRequestTable
		applyValidityFunctions(requestTable)

		if #LazyCrafter:findItemByReference(requestTable["Reference"]) == 0 then
			d("Was not added")
			zo_calLater(function() d("Attempt to add again")addPatternToQueue(patternButton, i) end, 1000)
		end
		return requestTable
	end
end



function DolgubonSetCrafter.compileMatRequirements()
	out("")
	for i = 1, #DolgubonSetCrafter.patternButtons do
		--d(DolgubonSetCrafter.patternButtons[i].tooltip..DolgubonSetCrafter.patternButtons[i].selectedIndex)
		if DolgubonSetCrafter.patternButtons[i].toggleValue then
			local request =addPatternToQueue(DolgubonSetCrafter.patternButtons[i],i)
			if request then
				queue[#queue+1] = request
			end
		end
	end
end

function DolgubonSetCrafter.craft() 

	DolgubonSetCrafter.compileMatRequirements() 
	DolgubonSetCrafter.updateList()
end


function DolgubonSetCrafter.craftConfirm()
	DolgubonSetCrafter.compileMatRequirements()
	DolgubonSetCrafterConfirm:SetHidden(false)
end

function DolgubonSetCrafter.removeFromScroll(reference)

	local removalFunction
	if type(reference) == "table" then
		removalFunction = reference.onClickety
		reference = reference.Reference
	end
	if GetDisplayName() =="@Dolgubon" then  d(reference) end

	for k, v in pairs(queue) do
		if v.Reference == reference then
			table.remove(queue,k)
		end
	end
	if removalFunction then
		removalFunction()
	else
		LazyCrafter:cancelItemByReference(reference)
	end

	table.sort(queue, function(a,b) if a~=nil and b~=nil then return a["Reference"]>b["Reference"] else return b==nil end end)
	DolgubonSetCrafter.updateList()
	
end
SetCrafterResults = {}
local function LLCCraftCompleteHandler(event, station, resultTable)
	SetCrafterResults[#SetCrafterResults + 1] = {["event"] = event, ["reference"] = resultTable["reference"]}
	if event ~=LLC_CRAFT_SUCCESS then return end
	DolgubonSetCrafter.removeFromScroll(resultTable["reference"])

end

function DolgubonSetCrafter.clearQueue()
	for i = #queue, 1, -1 do
		DolgubonSetCrafter.removeFromScroll(queue[i].Reference)
	end

end



function DolgubonSetCrafter.initializeFunctions.initializeCrafting()
	queue = DolgubonSetCrafter.savedVars.queue

	LazyCrafter = LibLazyCrafting:AddRequestingAddon(DolgubonSetCrafter.name, false, LLCCraftCompleteHandler)	
	DolgubonSetCrafter.LazyCrafter = LazyCrafter
	for k, v in pairs(queue) do 
		if not v.doNotKeep then
			LazyCrafter:CraftSmithingItemByLevel(unpack(v["CraftRequestTable"]))
			if pcall(function()applyValidityFunctions(v)end) then else d("Request could not be displayed. However, you should still be able to craft it.") end
		else
			table.remove(queue, k)
		end
	end
end



local function findPatternName(pattern, station)
	local weight
	local patternName
	if station == CRAFTING_TYPE_CLOTHIER and pattern < 9 then
		weight = DolgubonSetCrafter.localizedStrings.armourTypes[3]
	elseif station == CRAFTING_TYPE_CLOTHIER then
		weight = DolgubonSetCrafter.localizedStrings.armourTypes[2]
	elseif station == CRAFTING_TYPE_BLACKSMITHING and pattern > 7 then
		weight = DolgubonSetCrafter.localizedStrings.armourTypes[1]
	else
		weight = ""
	end
	if weight ~= "" then
		if station == CRAFTING_TYPE_CLOTHIER then
			if pattern == 2 then
				patternName = DolgubonSetCrafter.localizedStrings.armourTypes[8]
			elseif pattern == 1 then
				patternName = DolgubonSetCrafter.localizedStrings.armourTypes[1]
			else
				patternName = DolgubonSetCrafter.localizedStrings.armourTypes[(pattern - 1)%7]
			end
		elseif station == CRAFTING_TYPE_BLACKSMITHING then
			patternName = DolgubonSetCrafter.localizedStrings.armourTypes[pattern%7]
		end
	elseif station == CRAFTING_TYPE_WOODWORKING then
		if pattern == 2 then
			patternName = DolgubonSetCrafter.localizedStrings.weaponNames [13]
		elseif pattern == 1 then
			patternName = DolgubonSetCrafter.localizedStrings.weaponNames [8]
		else
			patternName = DolgubonSetCrafter.localizedStrings.weaponNames [pattern + 6]
		end

	else
		patternName = DolgubonSetCrafter.localizedStrings.weaponNames[pattern]
	end
	return patternName, weight,1
end


local function findIndexName(index, table)
	for i = 1, #table do 
		if table[i][1] == index then
			return table[i][2]
		end
	end
	return ""
end


-- autocraft is ignored right now, and will automatically be true, as there is currently no set crafter support for non autocraft
-- The function will return a reference that can be used to find the craft request again.
-- Test function: /script d(DolgubonSetCrafter.AddSmithingRequest(1, true, 10, 5, 7, false, 6, 1, 1, true))
local function AddForiegnSmithingRequest(pattern, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, station, setIndex, quality, autocraft, reference, craftingObject)

	local queueTable = {}
	if pattern and isCP ~= nil and level and styleIndex and traitIndex and station and setIndex and quality then

		queueTable.personalReference 					= reference
		if reference == nil then reference = DolgubonSetCrafter.savedVars.counter end
		queueTable.Reference 							= DolgubonSetCrafter.savedVars.counter
		DolgubonSetCrafter.savedVars.counter 			= DolgubonSetCrafter.savedVars.counter + 1
		queueTable.CraftRequestTable 					= {pattern, isCP,level ,styleIndex,traitIndex, useUniversalStyleItem, station,  setIndex, quality, true, reference}

		craftingObject:CraftSmithingItemByLevel(
			queueTable.CraftRequestTable[1],
			queueTable.CraftRequestTable[2],
			queueTable.CraftRequestTable[3],
			queueTable.CraftRequestTable[4],
			queueTable.CraftRequestTable[5],
			queueTable.CraftRequestTable[6],
			queueTable.CraftRequestTable[7],
			queueTable.CraftRequestTable[8],
			queueTable.CraftRequestTable[9],
			queueTable.CraftRequestTable[10],
			queueTable.CraftRequestTable[11]
			)
		local patternName, weightClassName, weightID	= findPatternName(pattern, station )
		queueTable.Pattern 								= {pattern, patternName}
		queueTable.Weight 								= {weightID, weightClassName}
		local levelName 								= tostring(level)
		if isCP then levelName 							= "CP"..levelName end
		queueTable.Level								= {level, levelName}
		queueTable.Style 								= {styleIndex, findIndexName(styleIndex, DolgubonSetCrafter.styleNames)}
		if queueTable.Weight[2] == "" then
			queueTable.Trait 							= {traitIndex, findIndexName(traitIndex, DolgubonSetCrafter.weaponTraits)}
		else
			queueTable.Trait 							= {traitIndex, findIndexName(traitIndex, DolgubonSetCrafter.armourTraits)}
		end
		queueTable.Set 									= {setIndex, findIndexName(setIndex, DolgubonSetCrafter.setIndexes)}
		queueTable.Quality 								= {quality, DolgubonSetCrafter.quality[quality][2]}
		
		--LLC_CraftSmithingItemByLevel(self, patternIndex, isCP , level, styleIndex, traitIndex, useUniversalStyleItem, stationOverride, setIndex, quality, autocraft)
		
		applyValidityFunctions(queueTable)
		queue[#queue + 1] = queueTable
	else
		d("Set Crafter: Not all required parameters were given for the public API")
	end
	DolgubonSetCrafter.updateList()
	return queueTable
end

function DolgubonSetCrafter.AddSmithingRequest(pattern, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, station, setIndex, quality, autocraft)
	local t = AddForiegnSmithingRequest(pattern, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, station, setIndex, quality, autocraft, nil, LazyCrafter)
	
	return t.Reference
end

function DolgubonSetCrafter.AddSmithingRequestWithReference(pattern, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, station, setIndex, quality, autocraft, optionalReference, optionalCraftingObject)

	local t =AddForiegnSmithingRequest(pattern, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, station, setIndex, quality, autocraf, optionalReference, optionalCraftingObject)
	t.onClickety = function() optionalCraftingObject:cancelItemByReference(optionalReference) end
	t.doNotKeep = true

end


local function slotUpdate( eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if isNewItem then
		--dwd(GetItemLink(bagId, slotId))
	end
end
EVENT_MANAGER:RegisterForEvent("Set Crafter", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, slotUpdate)

	--[[@Dolgubon: label: offsetX -10 -> offsetX -160, toggleCp: offsetX -100 -> offsetX -85, box: 
IDK because of the two anchors, but that will align the label and the thingy at least.
Also, you could put the parent element's offsetY from 40 to 55. 
I suppose the Attributes header could also go, since the things are pretty self-explanatory? http://take.ms/GIpvU
TEXT_TYPE_ALL
TEXT_TYPE_ALPHABETIC
TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN
TEXT_TYPE_NUMERIC
TEXT_TYPE_NUMERIC_UNSIGNED_INT
TEXT_TYPE_PASSWORD
myInput:SetTextType(TEXT_TYPE_NUMERIC)


]]

--[[
Ok so if no crafting Object is given we make a reference as normal
But if one IS given then we need to make our own


]]
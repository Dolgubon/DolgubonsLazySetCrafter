-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
--local original = d local function d() original(pcall(function() error("There's a d() at this line!") end )) end
DolgubonSetCrafter = DolgubonSetCrafter or {}

function determineLine()
	local a, b  = pcall( function() local a = nil a = a+ 1 end) return b,  tonumber(string.match (b, "^%D*%d+%D*%d+%D*%d+%D*%d+%D*(%d+)" ))
end

local originalD = d
local function d(...)
	if GetDisplayName()=="@Dolgubon" then 
		originalD(...)
	end
end


local queue

local craftedItems = {}
local function removeFromScroll()
end

local function getItemLinkFromItemId(itemId) 
	return string.format("|H0:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, 0, ITEMSTYLE_NONE, 0, 10000) 
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
		if station == CRAFTING_TYPE_CLOTHIER then
			if pattern > 1 then pattern = pattern - 1 end
		end
		local traitIndex,_,known = GetSmithingResearchLineTraitInfo(station, pattern, i)
		
		if known then
			count = count + 1
		end
		
		if traitIndex == trait then
			traitKnown = known
			
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

local validityFunctions = --stuff that's not here will automatically recieve a value of true.
{ -- Second value is the required parameters from the craftrequesttable needed to determine ability to craft
	["Trait"] = {function(...) local a = isTraitKnown(...) return a end , {7, 1,5, 8}},
	["Set"] = {function(...)local _,a = isTraitKnown(...) return a end , {7,1,5,8}},
	["Style"] = {isStyleKnownForPattern , {4, 7, 1}},
}



-- uses the info in validityFunctions to recheck and see if attributes are an impediment to crafting.
local function applyValidityFunctions(requestTable) 
	for attribute, table in pairs(validityFunctions) do
		if requestTable["Station"] == 7 and attribute == "Style" then
		else
			local params = {}

			for i = 1, #table[2]  do

				params[#params + 1] = requestTable["CraftRequestTable"][table[2][i]]

			end
			--d("one application for: "..attribute)
			requestTable[attribute][3] = table[1](unpack(params) )
		end
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

local function addRequirements(returnedTable, addAmounts)
	DolgubonSetCrafter.materialList = DolgubonSetCrafter.materialList or {}
	local parity = -1
	if addAmounts then parity = 1 end

	local requirements = LazyCrafter:getMatRequirements(returnedTable)

	for itemId, amount in pairs(requirements) do
		local link = getItemLinkFromItemId(itemId)
		local bag, bank, craft = GetItemLinkStacks(link)
		if DolgubonSetCrafter.materialList[itemId] then
			DolgubonSetCrafter.materialList[itemId]["Amount"] = DolgubonSetCrafter.materialList[itemId]["Amount"] + amount*parity
			DolgubonSetCrafter.materialList[itemId]["Current"] = bag + bank + craft
		else
			DolgubonSetCrafter.materialList[itemId] = {["Name"] = link ,["Amount"] = amount*parity,["Current"] = bag + bank + craft }
		end
		if DolgubonSetCrafter.materialList[itemId]["Amount"] <= 0 then DolgubonSetCrafter.materialList[itemId] = nil end
	end
end

local function clearTable (t)
	for k, v in pairs(t) do
		t[k] = nil
	end
end

function DolgubonSetCrafter.recompileMatRequirements()
	clearTable(DolgubonSetCrafter.materialList)
	for station, stationQueue in pairs( LazyCrafter.personalQueue) do
		for queuePosition, request in pairs(stationQueue) do
			addRequirements(request, true)
		end
	end
end

local function oneDeepCopy(t)
	local newTable = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			newTable[k] = {}
			for dk, dv in pairs(v) do
				newTable[k][dk] = dv
			end
		else
			newTable[k] = v
		end
	end
	return newTable
end


local function addPatternToQueue(patternButton,i)
	local function shallowTwoItemCopy(t)
		return {t[1],t[2]}
	end
	local comboBoxes = DolgubonSetCrafter.ComboBox
	local requestTable = {}
	
	local pattern, station  = 0, 0
	local trait = 0
	local isArmour 

	-- Weight
	if patternButton:HaveWeights() then
		requestTable["Weight"] = {DolgubonSetCrafter:GetWeight()}
	else
		requestTable["Weight"] = {nil, ""}
	end

	-- Station
	station = patternButton:GetStation()
	requestTable["Station"] = station

	-- Pattern
	pattern = patternButton:GetPattern(requestTable["Weight"][1])
	requestTable["Pattern"] = {pattern,patternButton.tooltip}

	-- Traits
	local traitTable, enchantTable = patternButton:TraitsToUse()
	if traitTable.invalidSelection() and not DolgubonSetCrafter.savedvars.autofill then
		out(traitTable.selectPrompt)
		return
	end
	if enchantTable.invalidSelection() and not DolgubonSetCrafter.savedvars.autofill then
		out(enchantTable.selectPrompt)
		return
	end
	trait = traitTable.selected[1]
	requestTable["Trait"] = {trait, traitTable.selected[2] }

	--Styles
	if patternButton:UseStyle() then
		requestTable["Style"] 	= shallowTwoItemCopy(comboBoxes.Style.selected)
		styleIndex 				= comboBoxes.Style.selected[1]
	else
		styleIndex 				= 0 
	end

	local level, isCP = DolgubonSetCrafter:GetLevel()
	
	requestTable["Level"] = {level, level} -- doubled to simplify code in other areas


	requestTable["Set"]			= shallowTwoItemCopy(comboBoxes.Set.selected)
	local setIndex 				= comboBoxes.Set.selected[1]

	requestTable["Quality"]		= shallowTwoItemCopy(comboBoxes.Quality.selected)
	local quality 				= comboBoxes.Quality.selected[1]

	-- Check that all selections are valid, i.e. valid level and not 'select trait'
	if not level then -- is a level entered?
		requestTable["Level"][1]=nil 
		out(DolgubonSetCrafterWindowInputInputBox.selectPrompt) 
		return
		-- Is the level valid?
	elseif not LazyCrafter.isSmithingLevelValid(  isCP, requestTable["Level"][1] ) then 
		out(DolgubonSetCrafter.localizedStrings.UIStrings.invalidLevel)
		return
	end
	-- Are all the combobox selections valid? We already checked traits though, so filter those out
	for k, combobox in pairs(comboBoxes) do
		if combobox.invalidSelection() and not DolgubonSetCrafter.savedvars.autofill then
			if combobox.isTrait or combobox.isGlyph then
			elseif (combobox.isStyle and  patternButton:UseStyle()) or not combobox.isStyle  then
				if combobox.isGlyphQuality then
					if enchantTable.selected[1] == 0 then
					else
						out(combobox.selectPrompt)
						return
					end
				else
					out(combobox.selectPrompt)
					return
				end
			end
		end
	end

	-- Some names are just so long, we need to shorten it
	shortenNames(requestTable)
	-- double checking one final time
	if pattern and isCP ~= nil and requestTable["Level"][1] and (styleIndex or station == 7) and trait and station and setIndex and quality then
		local craftMultiplier = DolgubonSetCrafter:GetMultiplier()
		craftMultiplier = math.max(math.floor(craftMultiplier), 1) -- Make it an integer, also make it minimum of 1
		for i = 1, craftMultiplier do
			-- First, create a deep(er) copy. Tables only go down one deep so that's max depth we need to copy
			local requestTableCopy = oneDeepCopy(requestTable)
			-- increment counter for unique reference
			requestTableCopy["Reference"]	= DolgubonSetCrafter.savedvars.counter
			DolgubonSetCrafter.savedvars.counter = DolgubonSetCrafter.savedvars.counter + 1
			local enchantRequestTable
			

			local CraftRequestTable = {
				pattern, 
				isCP,
				tonumber(requestTableCopy["Level"][1]),
				styleIndex,
				trait, 
				DolgubonSetCrafter:GetMimicStoneUse(), 
				station,  
				setIndex, 
				quality, 
				DolgubonSetCrafter:GetAutocraft(),
				requestTableCopy["Reference"],
			}

			local returnedTable = LazyCrafter:CraftSmithingItemByLevel(unpack(CraftRequestTable))
			local enchantRequestTable
			if enchantTable.selected[1] ~= 0 then
				local enchantLevel = LibLazyCrafting.closestGlyphLevel(isCP, CraftRequestTable[3])
				enchantRequestTable = LazyCrafter:CraftEnchantingGlyphByAttributes(isCP, enchantLevel, 
					enchantTable.selected[1], DolgubonSetCrafter.ComboBox.EnchantQuality.selected[1], 
					DolgubonSetCrafter:GetAutocraft(), requestTableCopy["Reference"], returnedTable)

				requestTableCopy["Enchant"] = enchantTable.selected
				requestTableCopy["EnchantQuality"] = DolgubonSetCrafter.ComboBox.EnchantQuality.selected[1]
				table.insert(CraftRequestTable,enchantRequestTable.potencyItemID)
				table.insert(CraftRequestTable,enchantRequestTable.essenceItemID)
				table.insert(CraftRequestTable,enchantRequestTable.aspectItemID)
			else
				requestTableCopy["Enchant"] = ""
				requestTableCopy["EnchantQuality"] =1
			end

			--LLC_CraftSmithingItemByLevel(self, patternIndex, isCP , level, styleIndex, traitIndex, useUniversalStyleItem, stationOverride, setIndex, quality, autocraft)
			if isCP then
				requestTableCopy["Level"][2] = "CP ".. requestTableCopy["Level"][2]
			end
			requestTableCopy["CraftRequestTable"] = CraftRequestTable
			if enchantRequestTable then
				requestTableCopy["Link"] = LazyCrafter.getItemLinkFromParticulars(setIndex,trait, pattern, station, CraftRequestTable[3], isCP,  quality, styleIndex,
					enchantRequestTable.potencyItemID,enchantRequestTable.essenceItemID,  enchantRequestTable.aspectItemID)
			else
				requestTableCopy["Link"] = LazyCrafter.getItemLinkFromParticulars(setIndex,trait, pattern, station, CraftRequestTable[3], isCP,  quality, styleIndex)
			end
			applyValidityFunctions(requestTableCopy)
			if returnedTable then
				addRequirements(returnedTable, true)
			end
			if requestTableCopy then
				queue[#queue+1] = requestTableCopy
			end
		end
	end
end



function DolgubonSetCrafter.compileMatRequirements()
	out("")
	local patternButtonSelected = false
	for i = 1, #DolgubonSetCrafter.patternButtons do
		--d(DolgubonSetCrafter.patternButtons[i].tooltip..DolgubonSetCrafter.patternButtons[i].selectedIndex)
		if DolgubonSetCrafter.patternButtons[i].toggleValue then
			patternButtonSelected = true
			addPatternToQueue(DolgubonSetCrafter.patternButtons[i],i)

		end
	end
	if not patternButtonSelected then
		out(zo_strformat(DolgubonSetCrafter.localizedStrings.UIStrings.selectPrompt,DolgubonSetCrafter.localizedStrings.UIStrings.pattern))
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

function DolgubonSetCrafter.removeFromScroll(reference, resultTable)

	local requestTable = LazyCrafter:findItemByReference(reference)[1] or resultTable

	if requestTable then 
		addRequirements(requestTable, false)
	end

	local removalFunction
	if type(reference) == "table" then
		removalFunction = reference.onClickety
		reference = reference.Reference
	end
	

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

local function LLCCraftCompleteHandler(event, station, resultTable)	
	if event ==LLC_CRAFT_SUCCESS then 
		if resultTable.type == "improvement" then 
			resultTable.station = GetRearchLineInfoFromRetraitItem(BAG_BACKPACK, resultTable.ItemSlotID) 
		end
		DolgubonSetCrafter.removeFromScroll(resultTable.reference, resultTable)
	elseif event == LLC_INITIAL_CRAFT_SUCCESS then
		-- DolgubonSetCrafter.recompileMatRequirements()
		DolgubonSetCrafter.updateList()
	end
end

function DolgubonSetCrafter.clearQueue()
	for i = #queue, 1, -1 do
		DolgubonSetCrafter.removeFromScroll(queue[i].Reference)
	end

end



function DolgubonSetCrafter.initializeFunctions.initializeCrafting()
	queue = DolgubonSetCrafter.savedvars.queue

	LazyCrafter = LibLazyCrafting:AddRequestingAddon(DolgubonSetCrafter.name, false, LLCCraftCompleteHandler)
	DolgubonSetCrafter.LazyCrafter = LazyCrafter
	for k, v in pairs(queue) do 
		if not v.doNotKeep then

			local returnedTable = LazyCrafter:CraftSmithingItemByLevel(unpack(v["CraftRequestTable"]))
			addRequirements(returnedTable, true)
			if pcall(function()applyValidityFunctions(v)end) then else d("Request could not be displayed. However, you should still be able to craft it.") end
		else
			table.remove(queue, k)
		end
	end
	LazyCrafter:SetAllAutoCraft(DolgubonSetCrafter:GetSettings().autocraft)
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
		if reference == nil then reference = DolgubonSetCrafter.savedvars.counter end
		queueTable.Reference 							= DolgubonSetCrafter.savedvars.counter
		DolgubonSetCrafter.savedvars.counter 			= DolgubonSetCrafter.savedvars.counter + 1
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

function DolgubonSetCrafter.isRequestInProgressByReference(referenceId)
	local requestTable = LazyCrafter:findItemByReference(referenceId)
	return requestTable and requestTable[1] and (requestTable[1].type ~= "smithing" or requestTable[1].glyphCreated)
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

--[[
@Dolgubon I'd prefer getting fedback upon craft requests or what went wrong or what succeeded at a fixed line in your addon UI, 
bottom line like a status text. Having popups and tooltips everywhere is just annoying, and the click sound for each clicked entry etc. 
too btw! If you do a tooltip, please put everthing in one tooltip like Scootworks showed as example. If it's an error, colorize it red 
and/or (for the colorblinds) use an icon via zo_iconTextFormat to show it does not work.

]]
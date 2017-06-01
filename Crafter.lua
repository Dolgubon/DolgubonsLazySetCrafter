-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--

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

local function getNumTraitsKnown(station, pattern, trait) -- and if the trait is known
	local count = 0
	local traitKnown =false
	for i =1 ,9 do 
		local _,_,known = GetSmithingResearchLineTraitInfo(station, pattern - 1, i)
		local index = GetSmithingResearchLineTraitInfo(station, pattern, i)
		if known then
			count = count + 1
		end
		
		if index == trait then
			_,_, traitKnown = GetSmithingResearchLineTraitInfo(station, pattern, i)
			
		end
	end
	return count, traitKnown
end

local function isTraitKnown(station, pattern, trait, setIndex) -- more of a router than anything. Calls getNumTraitsKnown to do the work
	
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
	return known, number>= GetSetIndexes()[setIndex][3]
end

-- uses the info in validityFunctions to recheck and see if attributes are an impediment to crafting.
local function applyValidityFunctions(requestTable) 
	for k, v in pairs(validityFunctions) do
		local params = {}
		for i = 2, #v  do
			params[#params + 1] = requestTable["CraftRequestTable"][v[i]]
		end
		requestTable[k][3] = v[1](unpack(params) )
	end
end

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
	
	local requestTable = {}
	
	local pattern, station  = 0, 0
	local trait = 0

	if i<9 then
		for i = 1, 3 do 

			if DolgubonSetCrafter.armourTypes[i].toggleValue then

				
				requestTable["Weight"] = {1,DolgubonSetCrafter.armourTypes[i].tooltip}

				pattern, station = getPatternIndex(patternButton,i)
			end

		end
		requestTable["Trait"] = DolgubonSetCrafter.ComboBox.Armour.selected
		trait = DolgubonSetCrafter.ComboBox.Armour.selected[1]
	elseif i== 21 then
		requestTable["Weight"] = " "
		requestTable["Trait"] = DolgubonSetCrafter.ComboBox.Armour.selected
		pattern, station = getPatternIndex(patternButton)
		trait = DolgubonSetCrafter.ComboBox.Armour.selected[1]	
	else
		requestTable["Weight"] = ""
		requestTable["Trait"] = DolgubonSetCrafter.ComboBox.Weapon.selected
		pattern, station = getPatternIndex(patternButton)
		trait = DolgubonSetCrafter.ComboBox.Weapon.selected[1]
	end
	requestTable["Pattern"] = {pattern,patternButton.tooltip}
	requestTable["Level"] = {tonumber(DolgubonSetCrafterWindowInputBox:GetText()),DolgubonSetCrafterWindowInputBox:GetText()}
	if requestTable["Level"][2]=="" then requestTable["Level"][1]=nil out(DolgubonSetCrafterWindowInputBox.selectPrompt) return end
	for k, combobox in pairs(DolgubonSetCrafter.ComboBox) do
		if combobox.invalidSelection(requestTable["Weight"]) and not DolgubonSetCrafter.savedVars.autofill then
			out(combobox.selectPrompt)
			return
		end
	end

	
	local isCP = not DolgubonSetCrafterWindowInputToggleChampion.toggleValue
	requestTable["Style"] 		= DolgubonSetCrafter.ComboBox.Style.selected
	
	local styleIndex 			= DolgubonSetCrafter.ComboBox.Style.selected[1]
	requestTable["Set"]			= DolgubonSetCrafter.ComboBox.Set.selected
	

	local setIndex 				= DolgubonSetCrafter.ComboBox.Set.selected[1]
	requestTable["Quality"]		= DolgubonSetCrafter.ComboBox.Quality.selected
	
	local quality 				= DolgubonSetCrafter.ComboBox.Quality.selected[1]
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

	for k, v in pairs(queue) do
		if v.Reference == reference then
			table.remove(queue,k)
		end
	end
	LazyCrafter:cancelItemByReference(reference)
	table.sort(queue, function(a,b) if a~=nil and b~=nil then return a["Reference"]>b["Reference"] else return b==nil end end)
	DolgubonSetCrafter.updateList()
	
end

local function LLCCraftCompleteHandler(event, station, resultTable)
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
		LazyCrafter:CraftSmithingItemByLevel(unpack(v["CraftRequestTable"]))
		applyValidityFunctions(v)
	end
end

validityFunctions = --stuff that's not here will automatically recieve a value of true.
{
	["Trait"] = {function(...) local a = isTraitKnown(...) return a end , 7, 1,5, 8},
	["Set"] = {function(...)local _,a = isTraitKnown(...) return a end , 7,1,5,8},
	["Style"] = {IsSmithingStyleKnown , 4},
}



--[[@Dolgubon: label: offsetX -10 -> offsetX -160, toggleCp: offsetX -100 -> offsetX -85, box: 
IDK because of the two anchors, but that will align the label and the thingy at least.
Also, you could put the parent element's offsetY from 40 to 55. 
I suppose the Attributes header could also go, since the things are pretty self-explanatory? http://take.ms/GIpvU]]
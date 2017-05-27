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

local function findPreviouslyCraftedItem()

end

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

local function StripColorAndWhitespace(text)

	text = string.gsub(text, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]", "")
	text = string.gsub(text, "|r", "")
	return text
end

local function shortenNames(requestTable)

	for k,v in pairs(requestTable) do
		for i = 1, #shortVersions do

			v = StripColorAndWhitespace(v)

			if shortVersions[i][1] == v then

				requestTable[k] = shortVersions[i][2]
			end
		end
	end

	local colour = "|cFFFFFF"
	if not IsSmithingStyleKnown(requestTable["styleIndex"]) then colour = "|c808080" end
	requestTable["Style"] = colour..requestTable["Style"].."|r"

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
	requestTable["Pattern"] = patternButton.tooltip
	local pattern, station  = 0, 0
	local trait = 0

	if i<9 then
		for i = 1, 3 do 

			if DolgubonSetCrafter.armourTypes[i].toggleValue then

				
				requestTable["Weight"] = DolgubonSetCrafter.armourTypes[i].tooltip

				pattern, station = getPatternIndex(patternButton,i)
			end

		end
		requestTable["Trait"] = DolgubonSetCrafter.ComboBox.Armour.selected[2]
		trait = DolgubonSetCrafter.ComboBox.Armour.selected[1]
	elseif i== 21 then
		requestTable["Weight"] = " "
		requestTable["Trait"] = DolgubonSetCrafter.ComboBox.Armour.selected[2]
		pattern, station = getPatternIndex(patternButton)
		trait = DolgubonSetCrafter.ComboBox.Armour.selected[1]	
	else
		requestTable["Weight"] = ""
		requestTable["Trait"] = DolgubonSetCrafter.ComboBox.Weapon.selected[2]
		pattern, station = getPatternIndex(patternButton)
		trait = DolgubonSetCrafter.ComboBox.Weapon.selected[1]
	end

	requestTable["Level"] = DolgubonSetCrafterWindowInputBox:GetText()
	if requestTable["Level"]=="" then requestTable["Level"]=nil out(DolgubonSetCrafterWindowInputBox.selectPrompt) return end
	for k, combobox in pairs(DolgubonSetCrafter.ComboBox) do
		if combobox.invalidSelection(requestTable["Weight"]) then
			out(combobox.selectPrompt)
			return
		end
	end

	local isCP = not DolgubonSetCrafterWindowInputToggleChampion.toggleValue
	requestTable["Style"] 		= DolgubonSetCrafter.ComboBox.Style.selected[2]
	requestTable["styleIndex"]  = DolgubonSetCrafter.ComboBox.Style.selected[1]
	local styleIndex 			= DolgubonSetCrafter.ComboBox.Style.selected[1]
	requestTable["Set"]			= DolgubonSetCrafter.ComboBox.Set.selected[2]
	local setIndex 				= DolgubonSetCrafter.ComboBox.Set.selected[1]
	requestTable["Quality"]		= DolgubonSetCrafter.ComboBox.Quality.selected[2]
	local quality 				= DolgubonSetCrafter.ComboBox.Quality.selected[1]
	requestTable["Reference"]	= math.random()
	-- Some names are just so long, we need to shorten it
	shortenNames(requestTable)

	if pattern and isCP ~= nil and requestTable["Level"] and styleIndex and trait and station and setIndex and quality and requestTable["Reference"] then
		LazyCrafter:CraftSmithingItemByLevel(pattern, isCP,tonumber(requestTable["Level"]),styleIndex,trait, false, station,  setIndex, quality, true, requestTable["Reference"]  ) 
		local CraftRequestTable = {pattern, isCP,tonumber(requestTable["Level"]),styleIndex,trait, false, station,  setIndex, quality, true, requestTable["Reference"]}
		--LLC_CraftSmithingItemByLevel(self, patternIndex, isCP , level, styleIndex, traitIndex, useUniversalStyleItem, stationOverride, setIndex, quality, autocraft)
		if not DolgubonSetCrafterWindowInputToggleChampion.toggleValue then
			requestTable["Level"] = "CP"..requestTable["Level"]
		end
		requestTable["CraftRequestTable"] = CraftRequestTable
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
	table.sort(queue, function(a,b) if a~=nil and b~=nil then return a["Style"]>b["Style"] else return b==nil end end)
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
	for k, v in pairs(queue) do
		v["Style"] =  StripColorAndWhitespace(v["Style"])
		local colour = "|cFFFFFF"
		if not IsSmithingStyleKnown(v["styleIndex"]) then colour = "|c808080" end
		v["Style"] = colour..v["Style"].."|r"
	end

	LazyCrafter = LibLazyCrafting:AddRequestingAddon(DolgubonSetCrafter.name, false, LLCCraftCompleteHandler)	
	DolgubonSetCrafter.LazyCrafter = LazyCrafter
	for k, v in pairs(queue) do 
		LazyCrafter:CraftSmithingItemByLevel(unpack(v["CraftRequestTable"]))
	end
end


--[[@Dolgubon: label: offsetX -10 -> offsetX -160, toggleCp: offsetX -100 -> offsetX -85, box: 
IDK because of the two anchors, but that will align the label and the thingy at least.
Also, you could put the parent element's offsetY from 40 to 55. 
I suppose the Attributes header could also go, since the things are pretty self-explanatory? http://take.ms/GIpvU]]
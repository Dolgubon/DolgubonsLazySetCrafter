RecipeScrollList = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.RecipeScrollList = RecipeScrollList
CategoryScrollList = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.CategoryScrollList = CategoryScrollList

DolgubonSetCrafter = DolgubonSetCrafter or {}
DolgubonSetCrafter.initializeFunctions = DolgubonSetCrafter.initializeFunctions or {}
local createToggle = DolgubonSetCrafter.createToggle
local colours = 
{
	[1] = {["selected"] = {1,1,0.3},["mouseOverSelected"]={},},
	[2] = {["selected"] = {0, 1, 0.5},["mouseOverSelected"]={},},
	-- [3] = {["selected"] = {},["mouseOver"]={},},
	-- [4] = {["selected"] = {},["mouseOver"]={},},
	-- [5] = {["selected"] = {},["mouseOver"]={},},
}
local mySetColor
local selectedMult = 1.7
local mouseOverSelected = 0.9
local out = DolgubonSetCrafter.out
local filterFunctions =
{
	["find"] = function(resultName, searchText, simpleSearch)
		-- return string.find(name:lower(), text:lower())
		return string.find(resultName:lower(), searchText)
	end,
	["startsWith"] = function(resultName, searchText, simpleSearch)
		return string.startsWith(resultName:lower(), searchText)
	end,
}

local recipeListIndexPartitions = 
{
	['all'] = {},
	['food'] = {1,2,3,4,5,6,7,15},
	['drinks'] = {8,9,10,11,12,13,14,16},
	['furniture'] = {17,18,19,20,21,22,23,24,25,26,27,28,29,30},
	['furniture1'] = {17,18,19,20},
	['furniture2'] = {21,22},
	['furniture3'] = {23,24},
	['furniture4'] = {25, 26,},
	['furniture5'] = {27,28,29,30},
}

local visiblePartitions = 
{
	["allSelected"] = true,
	["individualSelections"] = {}
}

-- local function recipeListIndexIterator(fullList)
-- 	if 
-- end
local function determinePartition()
	if DolgubonSetCrafterWindowFurnitureFood.toggleValue then
		return recipeListIndexPartitions['food']
	elseif DolgubonSetCrafterWindowFurnitureDrinks.toggleValue then
		return recipeListIndexPartitions['drinks']
	elseif DolgubonSetCrafterWindowFurnitureFurniture.toggleValue then
		return recipeListIndexPartitions['furniture']
	end
end

function DolgubonSetCrafter.isCurrentlyInFurniture()
	return DolgubonSetCrafterWindowToggleFurniture.isCurrentUIFurniture
end

function DolgubonSetCrafter.toggleFurnitureUI(toggleButton)
	toggleButton.isCurrentUIFurniture = not toggleButton.isCurrentUIFurniture
	local newHidden = toggleButton.isCurrentUIFurniture
	DolgubonSetCrafterWindowPatternInput:SetHidden(newHidden)
	DolgubonSetCrafterWindowComboboxes:SetHidden(newHidden)
	DolgubonSetCrafterWindowInput:SetHidden(newHidden)
	DolgubonSetCrafterWindowFurniture:SetHidden(not newHidden)
	DolgubonSetCrafter:GetSettings().initialFurniture = toggleButton.isCurrentUIFurniture
	if toggleButton.isCurrentUIFurniture then
		out("Please select a recipe to craft")
	else
		out(DolgubonSetCrafter.localizedStrings.UIStrings.patternHeader)
	end
end

local function onMouseEnterHook(self)
	local data = self.data
	InitializeTooltip(ItemTooltip, self, LEFT, 250, 0, RIGHT)
	local itemLink = data.itemLink
	ItemTooltip:SetLink(itemLink)
	if self:IsSelected() then
		local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)
		if colours[data.quality] and colours[data.quality]["selected"] then
			r,g,b = unpack(colours[data.quality]["selected"])
		end
		self:mySetColor( r*mouseOverSelected,g*mouseOverSelected,b*mouseOverSelected, 1)
	else
		local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)
		self:mySetColor( r*0.7,g*0.7,b*0.7, 1)
		self.text = self
	end
end

local function onMouseExitHook(control)
	ClearTooltip(ItemTooltip)

	local data = control.data
	if control:IsSelected() then
		local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)
		if colours[data.quality] and colours[data.quality]["selected"] then
			r,g,b = unpack(colours[data.quality]["selected"])
		end
		control:mySetColor( r*selectedMult,g*selectedMult,b*selectedMult, 1)
	else
		control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
	end
end

local function toggleOthersOff(self)
	for _,button in pairs(DolgubonSetCrafter.recipeToggles) do
		if self ~= button then
			button:toggleOff()
		end
	end
	visiblePartitions = {
		["allSelected"] = true,
		["individualSelections"] = {}
	}
end
local function recipePartitionToggle(self)
	-- One button should always be active, so we do not want to toggle off when clicked
	if not self.toggleValue then
		self:toggleOn()
		return DolgubonSetCrafter:RefreshRecipeList()
	end
end

local function setupPartitionToggles()
	DolgubonSetCrafter.recipeToggles = {DolgubonSetCrafterWindowFurnitureFood,DolgubonSetCrafterWindowFurnitureDrinks, DolgubonSetCrafterWindowFurnitureFurniture }
	DolgubonSetCrafter.toggleFood = DolgubonSetCrafterWindowFurnitureFood
	DolgubonSetCrafter.toggleDrinks = DolgubonSetCrafterWindowFurnitureDrinks
	DolgubonSetCrafter.toggleFurniture = DolgubonSetCrafterWindowFurnitureFurniture
	createToggle(DolgubonSetCrafterWindowFurnitureFood,
		"/esoui/art/treeicons/provisioner_indexicon_meat_down.dds",
		"/esoui/art/treeicons/provisioner_indexicon_meat_up.dds",
		"/esoui/art/crafting/provisioner_indexicon_meat_over.dds",
		"/esoui/art/crafting/provisioner_indexicon_meat_over.dds",
		true)
	createToggle(DolgubonSetCrafterWindowFurnitureDrinks,
		"/esoui/art/treeicons/provisioner_indexicon_wine_down.dds",
		"/esoui/art/tutorial/provisioner_indexicon_wine_up.dds",
		"/esoui/art/treeicons/provisioner_indexicon_wine_over.dds",
		"/esoui/art/treeicons/provisioner_indexicon_wine_over.dds",
		false)
	createToggle(DolgubonSetCrafterWindowFurnitureFurniture, 
		"/esoui/art/treeicons/housing_indexicon_suite_down.dds",
		"/esoui/art/treeicons/housing_indexicon_suite_up.dds",
		"/esoui/art/treeicons/housing_indexicon_suite_over.dds",
		"/esoui/art/treeicons/housing_indexicon_suite_over.dds", 
		false)
	DolgubonSetCrafter.toggleFood.tooltip = "Food"
	DolgubonSetCrafter.toggleDrinks.tooltip = "Drinks"
	DolgubonSetCrafter.toggleFurniture.tooltip = "Furniture"
	for _, button in pairs(DolgubonSetCrafter.recipeToggles) do
		button.toggle = recipePartitionToggle
		button.onToggleOn = toggleOthersOff
	end

end

local function RecipeScrollDeselectedEntry(control)
	control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, control.data.quality))
	control.selected = false
	control:SetText(control.data.name)
end

local function RecipeScrollEntrySelected(control, data, selected, reselectingDuringRebuild)
	control:SetSelected(selected)
	if selected then
		if RecipeScrollList.lastSelected then
			RecipeScrollDeselectedEntry(RecipeScrollList.lastSelected)
		end
		RecipeScrollList.lastSelected = control
		-- DolgubonSetCrafter.furnitureTooltip:SetHidden(true)	
		-- DolgubonSetCrafter.furnitureTooltip:ClearLines()
		local itemLink = data.itemLink
		DolgubonSetCrafter.selectedFurniture = GetItemLinkItemId(itemLink)
		DolgubonSetCrafter.selectedFurnitureLink = itemLink
		DolgubonSetCrafter.selectedRecipeListIndex = data.recipeListIndex
		DolgubonSetCrafter.selectedRecipeIndex = data.recipeIndex
		local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)
		if colours[data.quality] and colours[data.quality]["selected"] then
			r,g,b = unpack(colours[data.quality]["selected"])
		end
		control:mySetColor( r*selectedMult,g*selectedMult,b*selectedMult, 1.5)
		DolgubonSetCrafterWindowFurnitureSelectedItem:SetText("Selected: "..GetItemLinkName(itemLink))
		DolgubonSetCrafterWindowFurnitureSelectedItem:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
		DolgubonSetCrafterWindowFurnitureSelectedItem.itemLink = itemLink
		control:SetText(control:GetText().."  <")
		control.questPin:SetTexture("/esoui/art/cadwell/check.dds")
		control.questPin:SetHidden(false)
		control.questPin:SetDimensions(16, 16)
		-- DolgubonSetCrafter.furnitureTooltip:SetProvisionerResultItem(data.recipeListIndex , data.recipeIndex)
		-- d(data)
		-- DolgubonSetCrafter.furnitureTooltip:SetProvisionerResultItem()
	else
		control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
		RecipeScrollDeselectedEntry(RecipeScrollList.lastSelected)
	end
end


function RecipeScrollList:New(control)
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		Reference = {},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "ZO_ProvisionerNavigationEntry", 23.4, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "name", SorterKeys, self.currentSortOrder) end
	self.data = generateCompleteRecipeList()

	return self
end

function CategoryScrollList:New(control)
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		Reference = {},
	}
	
 	self.masterList = {}
 	ZO_ScrollList_AddDataType(self.list, 1, "PieceButtonTemplate", 35, function(control, data) self:SetupEntry(control, data) end)
 	-- ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "name", SorterKeys, self.currentSortOrder) end
	self.data = DolgubonSetCrafter.recipeLists
	return self
end

local function toggleSelectedCategory(categoryId)
	visiblePartitions.individualSelections[ categoryId] = not visiblePartitions.individualSelections[ categoryId]
	-- check if there's any others selected
	local anySelected = false
	for k, v in pairs(visiblePartitions.individualSelections) do
		anySelected = anySelected or v
	end
	visiblePartitions.allSelected = not anySelected
end

function CategoryScrollList:SetupEntry(control, data)
	-- control.icon:SetTexture(data.downIcon)
	-- control.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
	-- control.text:SetDimensionConstraints(0, 0, 260, 0)
	-- control.text:SetText(data.name)
	-- local shouldHide =true --  DolgubonSetCrafter.questRecipeLists[data.recipeListIndex] ~= true
	-- control.questPin:SetHidden(shouldHide)

	-- if not enabled then
	-- 	control.icon:SetDesaturation(1)
	-- 	control.icon:SetTexture(data.upIcon)
	-- elseif open then
	-- 	control.icon:SetDesaturation(0)
	-- 	control.icon:SetTexture(data.downIcon)
	-- else
	-- 	control.icon:SetDesaturation(0)
	-- 	control.icon:SetTexture(data.upIcon)
	-- end
	control:SetMouseOverTexture(data[1].overIcon)
	control:SetPressedMouseOverTexture(data[1].downIcon)
	control.tooltip = data[1].recipeListName
	if data[1].active then
		control:SetNormalTexture(data[1].downIcon) 
	else
		control:SetNormalTexture(data[1].upIcon) 
	end
	control.data = data
	control.toggle = function() 
		data[1].active = not data[1].active
		if data[1].active then
			control:SetNormalTexture(data[1].downIcon) 
		else
			control:SetNormalTexture(data[1].upIcon) 
		end
		toggleSelectedCategory(data[1].recipeListIndex)
		DolgubonSetCrafter.recipeScroll:RefreshData()
	end
end


function RecipeScrollList:SetupEntry(control, data)
	data = data[1]
	mySetColor = mySetColor or control.SetColor
	control.mySetColor = mySetColor
	control.SetColor = function() end -- Stop messing with my colours!!
	control.data = data
	control.meetsLevelReq = true -- DolgubonSetCrafter:PassesTradeskillLevelReqs(data.tradeskillsLevelReqs)
	control.meetsQualityReq = true -- DolgubonSetCrafter:PassesQualityLevelReq(data.qualityReq)
	control.enabled = enabled
	control.text = control -- Attempt to fix conflict between this and MRL
	control.questPin:SetTexture("/esoui/art/cadwell/check.dds")
	control.questPin:SetHidden(not data.isKnown)
	control.questPin:SetDimensions(16, 16)
	data.maxIterationsForIngredients = data.maxIterationsForIngredients or 0
	if data.maxIterationsForIngredients > 0 and enabled then
		control:SetText(zo_strformat(SI_PROVISIONER_RECIPE_NAME_COUNT, data.name, data.maxIterationsForIngredients))
	else
		control:SetText(zo_strformat(SI_PROVISIONER_RECIPE_NAME_COUNT_NONE, data.name))
	end
	control:SetSelected(false)
	
	ZO_PostHookHandler(control, "OnMouseEnter", onMouseEnterHook )
	ZO_PostHookHandler(control, "OnMouseExit" , onMouseExitHook )
	control:SetHandler("OnMouseUp" , function()RecipeScrollEntrySelected(control, data ,  true) end)
	control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
	ZO_SortFilterList.SetupRow(self, control, data)
end

function RecipeScrollList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end


function RecipeScrollList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	local partition = determinePartition()

	local keyedTable= {}
	for k, v in pairs(partition) do
		keyedTable[v] = true
	end
	if not visiblePartitions.allSelected then
		keyedTable = visiblePartitions.individualSelections
	end

	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end
	local includeUnknown = not DolgubonSetCrafter.includeKnownRecipes()
	local masterList = self.masterList
	for i = 1, #self.masterList do
		local data = masterList[i]
		local info = data[1]
		local include = includeUnknown or info.isKnown
		if include and keyedTable[info.recipeListIndex] and filterFunctionToUse(info.name, searchText) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(data.typeId or 1, data))
		end
	end
end
function CategoryScrollList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)

	ZO_ClearNumericallyIndexedTable(scrollData)
	local partition = determinePartition()
	local keyedTable= {}


	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end
	local masterList = self.masterList
	for k, v in pairs(partition) do
		local data = masterList[v]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(data.typeId or 1, data))
		keyedTable[v] = true
	end
	
	for i = 1, #self.masterList do
		local data = masterList[i]
		-- table.insert(scrollData, ZO_ScrollList_CreateDataEntry(data.typeId or 1, data))
	end
end

function DolgubonSetCrafter:InitializeRecipeScroll()
	setupPartitionToggles()
	DolgubonSetCrafter.furnitureContainer = DolgubonSetCrafterWindowFurniture
	DolgubonSetCrafter.recipeScroll = RecipeScrollList:New(DolgubonSetCrafter.furnitureContainer)

	DolgubonSetCrafter.furnitureTooltip = DolgubonSetCrafterWindowFurniture:GetNamedChild("Tooltip")
	DolgubonSetCrafter.categoryScroll = CategoryScrollList:New(DolgubonSetCrafterWindowFurnitureCategory)

	local isKnown = DolgubonSetCrafterWindowFurnitureIsKnownCheckbox
	DolgubonSetCrafter.createToggle(isKnown,"esoui/art/cadwell/checkboxicon_checked.dds", "esoui/art/cadwell/checkboxicon_unchecked.dds", 
		"esoui/art/cadwell/checkboxicon_unchecked.dds", "esoui/art/cadwell/checkboxicon_unchecked.dds", DolgubonSetCrafter.savedvars['showKnownFurniture'] )
	isKnown:GetNamedChild("Label"):SetText(DolgubonSetCrafter.localizedStrings.UIStrings.onlyKnownRecipes)
	isKnown.onToggle = function(self, state) 
		DolgubonSetCrafter:RefreshRecipeList()
		DolgubonSetCrafter.savedvars['showKnownFurniture'] = state
	end
	DolgubonSetCrafter.recipeScroll:RefreshData()
	DolgubonSetCrafter.categoryScroll:RefreshData()
end

function DolgubonSetCrafter.includeKnownRecipes()
	return DolgubonSetCrafterWindowFurnitureIsKnownCheckbox.toggleValue
end

local function RecipeComparator(left, right)
    return left.name < right.name
end
local function IterateKnownRecipes(recipeListIndex, craftingStationType)
    return function(_, lastIndex)
        return GetNextKnownRecipeForCraftingStation(recipeListIndex, craftingStationType, lastIndex)
    end
end

function string.startsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

local function recipeFilter(resultName, searchText, simpleSearch)
	-- return string.find(name:lower(), text:lower())
	return string.find(resultName:lower(), searchText)
end

-- If the search text is just one letter, it lags slightly, so we will only check the first letter
local function simpleRecipeFilter(resultName, searchText)
end

completeRecipeList = nil

function generateCompleteRecipeList()
    DolgubonSetCrafter.recipeLists = {}
    DolgubonSetCrafter.recipeList = {}
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local simpleSearch = searchText:len() == 1
    for recipeListIndex = 1, GetNumRecipeLists() do
        local recipeListName, numRecipes, upIcon, downIcon, overIcon, _, recipeListCreateSound = GetRecipeListInfo(recipeListIndex)
        local recipeList = DolgubonSetCrafter.recipeLists[recipeListIndex]
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, numIngredients, _, qualityReq, specialIngredientType, requiredCraftingStationType, itemId = GetRecipeInfo(recipeListIndex, recipeIndex)
            local name, resultIcon = GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
            if recipeName ~= "" and true then -- recipeFilter(name, searchText, simpleSearch) then
                local maxIterationsForIngredients = PROVISIONER_MANAGER:CalculateMaxIterationsForIngredients(recipeListIndex, recipeIndex, numIngredients)
                local tradeskillsLevelReqs = {}
                for tradeskillIndex = 1, GetNumRecipeTradeskillRequirements(recipeListIndex, recipeIndex) do
                    local tradeskill, levelReq = GetRecipeTradeskillRequirement(recipeListIndex, recipeIndex, tradeskillIndex)
                    tradeskillsLevelReqs[tradeskill] = levelReq
                end

                local itemLink = DolgubonSetCrafter.LazyCrafter.getItemLinkFromItemId(itemId)
                local displayQuality = GetItemLinkDisplayQuality(itemLink)
                local createSound = recipeListCreateSound
                if createSound == "" then
                    createSound = DEFAULT_RECIPE_CREATE_SOUND
                end
                local recipe =
                {
                    recipeListName = recipeListName,
                    recipeListIndex = recipeListIndex,
                    recipeIndex = recipeIndex,
                    qualityReq = qualityReq,
                    passesTradeskillLevelReqs = PROVISIONER_MANAGER:PassesTradeskillLevelReqs(tradeskillsLevelReqs),
                    passesQualityLevelReq = PROVISIONER_MANAGER :PassesQualityLevelReq(qualityReq),
                    specialIngredientType = specialIngredientType,
                    numIngredients = numIngredients,
                    maxIterationsForIngredients = maxIterationsForIngredients,
                    createSound = createSound,
                    iconFile = resultIcon,
                    displayQuality = displayQuality,
                    -- quality is deprecated, included here for addon backwards compatibility
                    quality = displayQuality,
                    tradeskillsLevelReqs = tradeskillsLevelReqs,
                    name = recipeName,
                    requiredCraftingStationType = requiredCraftingStationType,
                    resultItemId = itemId,
                    isKnown = isKnown,
                    itemLink = itemLink
                }

                if not recipeList then
                    recipeList =
                    {
                        recipeListName = recipeListName,
                        recipeListIndex = recipeListIndex,
                        upIcon = upIcon,
                        downIcon = downIcon,
                        overIcon = overIcon,
                        recipes = {}
                    }
                    DolgubonSetCrafter.recipeLists[recipeListIndex] = recipeList
                end
                table.insert(DolgubonSetCrafter.recipeList , recipe)
                table.insert(recipeList.recipes, recipe)
            end
        end

        if recipeList then
            table.sort(recipeList.recipes, RecipeComparator)
        end
    end
    return DolgubonSetCrafter.recipeList
end

-- If the search text is just one letter, it lags slightly, so we will only check the first letter
local function simpleRecipeFilter(resultName, searchText)
end


function DolgubonSetCrafter:loadPartition(partition)
	local knowAnyRecipesInTab = false
	local hasRecipesWithFilter = false
	local requireIngredients = false -- ZO_CheckButton_IsChecked(self.haveIngredientsCheckBox)
	local requireSkills = false -- ZO_CheckButton_IsChecked(self.haveSkillsCheckBox)
	local requireQuests = false -- ZO_CheckButton_IsChecked(self.isQuestItemCheckbox)
	local craftingInteractionType = 1
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local filterFunctionToUse
	local recipeLists = completeRecipeList
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end
	for _, listIndex in pairs(partition) do
		local recipeList = recipeLists[listIndex]
		-- If user does not know any of the recipes, then skip
		if recipeList then
			local parent = self.recipeScroll.parents and self.recipeScroll.parents[listIndex]
			for _, recipe in ipairs(recipeList.recipes) do
				if true then --- recipe.requiredCraftingStationType == craftingInteractionType and self.filterType == recipe.specialIngredientType then
					knowAnyRecipesInTab = true
					if  filterFunctionToUse(recipe.name, searchText) then --recipeFilter(recipe.resultItemId) then -- does recipe pass filter
						parent = parent or self.recipeScroll:AddNode("ZO_ProvisionerNavigationHeader", {
								recipeListIndex = recipeList.recipeListIndex,
								name = recipeList.recipeListName,
								upIcon = recipeList.upIcon,
								downIcon = recipeList.downIcon,
								overIcon = recipeList.overIcon,
								})
						self.recipeScroll:AddNode("ZO_ProvisionerNavigationEntry", recipe, parent)
						hasRecipesWithFilter = true
					end
				end
			end
		end
	end
	-- Keep the first node closed for easy scrolling
	local origSelectAnything = DolgubonSetCrafter.recipeScroll.SelectAnything
	DolgubonSetCrafter.recipeScroll.SelectAnything = function() end
	self.recipeScroll:Commit()
	DolgubonSetCrafter.recipeScroll.SelectAnything = origSelectAnything
end
local currentConglomerateBatch = 0

function DolgubonSetCrafter:loadPartialConglomerate()
	currentConglomerateBatch = currentConglomerateBatch or 0
	currentConglomerateBatch = currentConglomerateBatch + 1
	local batchUnit = 20
	local timeSpacer = 125
	local batches = math.floor(#conglomeratedList/batchUnit) + 1
	-- DolgubonSetCrafter:loadAllParents()
	-- DolgubonSetCrafter.recipeScroll:SetEnabled(false)
	
	local startIndex = (currentConglomerateBatch-1) * batchUnit + 1
	local endIndex = currentConglomerateBatch * batchUnit

	local knowAnyRecipesInTab = false
	local hasRecipesWithFilter = false
	local requireIngredients = false -- ZO_CheckButton_IsChecked(self.haveIngredientsCheckBox)
	local requireSkills = false -- ZO_CheckButton_IsChecked(self.haveSkillsCheckBox)
	local requireQuests = false -- ZO_CheckButton_IsChecked(self.isQuestItemCheckbox)
	local craftingInteractionType = 1
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local filterFunctionToUse
	local recipeLists = completeRecipeList
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end
	for i = startIndex, endIndex do
		local recipe = conglomeratedList[i]
		if recipe then
			local parent = DolgubonSetCrafter.recipeScroll.parents and DolgubonSetCrafter.recipeScroll.parents[recipe.recipeListIndex]
			if parent then --recipeFilter(recipe.resultItemId) then -- does recipe pass filter
				DolgubonSetCrafter.recipeScroll:AddNode("ZO_ProvisionerNavigationEntry", recipe, parent)
			end
		end
	end
	-- Keep the first node closed for easy scrolling
	local origSelectAnything = DolgubonSetCrafter.recipeScroll.SelectAnything
	DolgubonSetCrafter.recipeScroll.SelectAnything = function() end
	DolgubonSetCrafter.recipeScroll:Commit()
	DolgubonSetCrafter.recipeScroll.SelectAnything = origSelectAnything
	if currentConglomerateBatch * batchUnit > #conglomeratedList then
		DolgubonSetCrafter.recipeScroll:SetEnabled(true)
		EVENT_MANAGER:UnregisterForUpdate(DolgubonSetCrafter.name .. "FurnitureTreeRefresh")
	end
end

local conglomerateParents = {}

function DolgubonSetCrafter:loadAllParents()
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local filterFunctionToUse
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end
	local recipeLists = completeRecipeList
	self.recipeScroll.parents = {}
	for listIndex, v in pairs(conglomerateParents) do
		local recipeList = recipeLists[listIndex]
		-- If user does not know any of the recipes, then skip
		if recipeList then
			local parent
			parent = parent or self.recipeScroll:AddNode("ZO_ProvisionerNavigationHeader", {
				recipeListIndex = recipeList.recipeListIndex,
				name = recipeList.recipeListName,
				upIcon = recipeList.upIcon,
				downIcon = recipeList.downIcon,
				overIcon = recipeList.overIcon,
				})
			self.recipeScroll.parents[listIndex] = parent
		end
	end
end

local function generateConglomerateRecipeList()
	conglomerateParents = {}
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local filterFunctionToUse
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end
	local partition = determinePartition()
	local conglomeratedList = {}
	for _, recipeListIndex in pairs(partition) do
		for k, recipe in pairs(completeRecipeList[recipeListIndex].recipes) do
			if filterFunctionToUse(recipe.name, searchText) and (not DolgubonSetCrafter.includeKnownRecipes() or recipe.isKnown) then
				table.insert(conglomeratedList, recipe)
				conglomerateParents[recipeListIndex] = true
			end
		end
	end
	return conglomeratedList
end


function DolgubonSetCrafter:RefreshRecipeList()
	DolgubonSetCrafter.recipeScroll:RefreshData()
	DolgubonSetCrafter.categoryScroll:RefreshData()
	if true then return end
	DolgubonSetCrafter.recipeScroll:Reset()
	local knowAnyRecipesInTab = false
	local hasRecipesWithFilter = false
	local requireIngredients = false -- ZO_CheckButton_IsChecked(self.haveIngredientsCheckBox)
	local requireSkills = false -- ZO_CheckButton_IsChecked(self.haveSkillsCheckBox)
	local requireQuests = false -- ZO_CheckButton_IsChecked(self.isQuestItemCheckbox)
	local craftingInteractionType = 1
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local filterFunctionToUse
	if searchText:len() < 3 then
		filterFunctionToUse = filterFunctions.startsWith
	else
		filterFunctionToUse = filterFunctions.find
	end

	local timeSpacer = 10
	if DolgubonSetCrafterWindowFurnitureFood.toggleValue or DolgubonSetCrafterWindowFurnitureDrinks.toggleValue then
		timeSpacer = 2
	end
	-- local recipeLists = PROVISIONER_MANAGER:GetRecipeListData(craftingInteractionType)
	completeRecipeList = completeRecipeList or generateCompleteRecipeList()
	local recipeLists = completeRecipeList
	conglomeratedList = generateConglomerateRecipeList()
	DolgubonSetCrafter:loadAllParents()
	currentConglomerateBatch = 0
	DolgubonSetCrafter.recipeScroll:SetEnabled(false)
	EVENT_MANAGER:UnregisterForUpdate(DolgubonSetCrafter.name .. "FurnitureTreeRefresh")
	EVENT_MANAGER:RegisterForUpdate(DolgubonSetCrafter.name .. "FurnitureTreeRefresh", timeSpacer ,  DolgubonSetCrafter.loadPartialConglomerate)


	
	if not hasRecipesWithFilter then
		if knowAnyRecipesInTab then
			-- self.noRecipesLabel:SetText(GetString(SI_PROVISIONER_NONE_MATCHING_FILTER))
		else
		end
		-- self:RefreshRecipeDetails()
	end

end

function RecipeScrollList:BuildMasterList()
	if self.masterListGenerated then return end
	self.masterListGenerated = true
	self.masterList = {}
	for k, recipeInfo in pairs(generateCompleteRecipeList()) do
		table.insert(self.masterList,{recipeInfo} )
	end
end

function CategoryScrollList:BuildMasterList()
	self.masterList = {}
	-- self.masterList = generateCompleteRecipeList()
	for k, recipeInfo in pairs(DolgubonSetCrafter.recipeLists) do
		table.insert(self.masterList,{recipeInfo} )
	end
end



DolgubonSetCrafter.initializeFunctions.InitializeFurnitureUI = DolgubonSetCrafter.InitializeRecipeScroll
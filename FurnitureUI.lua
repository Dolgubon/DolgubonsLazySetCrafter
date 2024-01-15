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


local function onMouseEnterHook(self)
	local data = self.data
	InitializeTooltip(ItemTooltip, self, LEFT, 205, 0, RIGHT)
	local itemLink = GetRecipeResultItemLink(data.recipeListIndex , data.recipeIndex)
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


function DolgubonSetCrafter:InitializeRecipeTree()
	setupPartitionToggles()

	DolgubonSetCrafter.navigationContainer = DolgubonSetCrafterWindowFurniture
	DolgubonSetCrafter.recipeTree = ZO_Tree:New(DolgubonSetCrafter.navigationContainer:GetNamedChild("ScrollChild"), 74, -10, 535)
	DolgubonSetCrafter.furnitureTooltip = DolgubonSetCrafterWindowFurniture:GetNamedChild("Tooltip")
	local function TreeHeaderSetup(node, control, data, open, userRequested, enabled)
		control.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
		control.text:SetDimensionConstraints(0, 0, 260, 0)
		control.text:SetText(data.name)
		local shouldHide =true --  DolgubonSetCrafter.questRecipeLists[data.recipeListIndex] ~= true
		control.questPin:SetHidden(shouldHide)

		if not enabled then
			control.icon:SetDesaturation(1)
			control.icon:SetTexture(data.upIcon)
		elseif open then
			control.icon:SetDesaturation(0)
			control.icon:SetTexture(data.downIcon)
		else
			control.icon:SetDesaturation(0)
			control.icon:SetTexture(data.upIcon)
		end

		control.iconHighlight:SetTexture(data.overIcon)

		ZO_IconHeader_Setup(control, open, enabled)
	end
	local function TreeHeaderEquality(left, right)
		return left.recipeListIndex == right.recipeListIndex
	end
	DolgubonSetCrafter.recipeTree:AddTemplate("ZO_ProvisionerNavigationHeader", TreeHeaderSetup, nil, TreeHeaderEquality, nil, 0)


	local function TreeEntrySetup(node, control, data, open, userRequested, enabled)
		mySetColor = mySetColor or control.SetColor
		control.mySetColor = mySetColor
		control.SetColor = function() end -- Stop messing with my colours!!
		control.data = data
		control.meetsLevelReq = true -- DolgubonSetCrafter:PassesTradeskillLevelReqs(data.tradeskillsLevelReqs)
		control.meetsQualityReq = true -- DolgubonSetCrafter:PassesQualityLevelReq(data.qualityReq)
		control.enabled = enabled
		control.text = control -- Attempt to fix conflict between this and MRL

		-- We're not using quest pins
		control.questPin:SetHidden(true)

		if data.maxIterationsForIngredients > 0 and enabled then
			control:SetText(zo_strformat(SI_PROVISIONER_RECIPE_NAME_COUNT, data.name, data.maxIterationsForIngredients))
		else
			control:SetText(zo_strformat(SI_PROVISIONER_RECIPE_NAME_COUNT_NONE, data.name))
		end
		control:SetEnabled(enabled)
		control:SetSelected(node:IsSelected())
		
		ZO_PostHookHandler(control, "OnMouseEnter", onMouseEnterHook )
		ZO_PostHookHandler(control, "OnMouseExit", onMouseExitHook )
		if WINDOW_MANAGER:GetMouseOverControl() == control then
			zo_callHandler(control, enabled and "OnMouseEnter" or "OnMouseExit")
		else
			ClearTooltip(ItemTooltip)
		end
		-- ZO_PostHook(node ,"OnUnselected", function() control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)) end)
		
		control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
	end
	local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
		control:SetSelected(selected)
		if selected then
			-- DolgubonSetCrafter.furnitureTooltip:SetHidden(true)	
			-- DolgubonSetCrafter.furnitureTooltip:ClearLines()
			local itemLink = GetRecipeResultItemLink(data.recipeListIndex , data.recipeIndex)
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
			-- DolgubonSetCrafter.furnitureTooltip:SetProvisionerResultItem(data.recipeListIndex , data.recipeIndex)
			-- d(data)
			-- DolgubonSetCrafter.furnitureTooltip:SetProvisionerResultItem()
		else
			control:mySetColor( GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
		end
	end
	local function TreeEntryEquality(left, right)
		return left.recipeListIndex == right.recipeListIndex and left.recipeIndex == right.recipeIndex and left.name == right.name
	end
	DolgubonSetCrafter.recipeTree:AddTemplate("ZO_ProvisionerNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)

	DolgubonSetCrafter.recipeTree:SetExclusive(true)
	DolgubonSetCrafter.recipeTree:SetOpenAnimation("ZO_TreeOpenAnimation")
	-- This override should allow the user to close open nodes
	function DolgubonSetCrafter.recipeTree:ToggleNode(treeNode)
    if treeNode:IsEnabled() and not treeNode:IsOpen() then
        if self.scrollControl and not treeNode:IsOpen() then
            self:SetScrollToTargetNode(treeNode)
        end
        self:SetNodeOpen(treeNode, not treeNode:IsOpen(), USER_REQUESTED_OPEN)
    else
    	self:SetNodeOpen(treeNode, not treeNode:IsOpen(), USER_REQUESTED_OPEN)
    end
end
	-- ZO_CraftingUtils_ConnectTreeToCraftingProcess(self.recipeTree)

	-- DolgubonSetCrafter:DirtyRecipeList()
	DolgubonSetCrafter:RefreshRecipeList()
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
	local searchText = DolgubonSetCrafterWindowFurnitureInputBox:GetText():lower()
	local simpleSearch = searchText:len() == 1
    for recipeListIndex = 1, GetNumRecipeLists() do
        local recipeListName, numRecipes, upIcon, downIcon, overIcon, _, recipeListCreateSound = GetRecipeListInfo(recipeListIndex)
        local recipeList = DolgubonSetCrafter.recipeLists[recipeListIndex]
        for currentCraftingStation = 1, 7 do
            for recipeIndex in IterateKnownRecipes(recipeListIndex, currentCraftingStation) do
                local _, recipeName, numIngredients, _, qualityReq, specialIngredientType, requiredCraftingStationType, itemId = GetRecipeInfo(recipeListIndex, recipeIndex)
                local name, resultIcon = GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
                if  true then -- recipeFilter(name, searchText, simpleSearch) then
	                local maxIterationsForIngredients = PROVISIONER_MANAGER:CalculateMaxIterationsForIngredients(recipeListIndex, recipeIndex, numIngredients)
	                local tradeskillsLevelReqs = {}
	                for tradeskillIndex = 1, GetNumRecipeTradeskillRequirements(recipeListIndex, recipeIndex) do
	                    local tradeskill, levelReq = GetRecipeTradeskillRequirement(recipeListIndex, recipeIndex, tradeskillIndex)
	                    tradeskillsLevelReqs[tradeskill] = levelReq
	                end

	                local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
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

	                table.insert(recipeList.recipes, recipe)
	            end
            end

            if recipeList then
                table.sort(recipeList.recipes, RecipeComparator)
            end
        end
    end
    return DolgubonSetCrafter.recipeLists
end

-- PROVISIONER_MANAGER = ZO_ProvisionerManager:New()
-- local function generateCompleteRecipeList()
-- 	local recipeList = {}
-- 	for recipeListIndex = 1, GetNumRecipeLists() do 
-- 		local name, numberRecipes, upIcon, downIcon, overIcon, _, createSound = GetRecipeListInfo(recipeListIndex)
-- 		recipeList[recipeListIndex] = {
-- 			["name"] = name,
-- 			["downIcon"] = downIcon,
-- 			["upIcon"] = upIcon,
-- 			["overIcon"] = overIcon,
-- 			["recipeListName"] = name,
-- 			["recipeListIndex"] = recipeListIndex,
-- 			["recipes"] = {},

-- 		}
-- 		for j = 1, numberRecipes do
-- 			local recipe =
--                 {
--                     recipeListName = recipeListName,
--                     recipeListIndex = recipeListIndex,
--                     recipeIndex = recipeIndex,
--                     qualityReq = qualityReq,
--                     passesTradeskillLevelReqs = self:PassesTradeskillLevelReqs(tradeskillsLevelReqs),
--                     passesQualityLevelReq = self:PassesQualityLevelReq(qualityReq),
--                     specialIngredientType = specialIngredientType,
--                     numIngredients = numIngredients,
--                     maxIterationsForIngredients = maxIterationsForIngredients,
--                     createSound = createSound,
--                     iconFile = resultIcon,
--                     displayQuality = displayQuality,
--                     -- quality is deprecated, included here for addon backwards compatibility
--                     quality = displayQuality,
--                     tradeskillsLevelReqs = tradeskillsLevelReqs,
--                     name = recipeName,
--                     requiredCraftingStationType = requiredCraftingStationType,
--                     resultItemId = itemId,
--                 }
-- 		end
-- 	end
-- end

-- If the search text is just one letter, it lags slightly, so we will only check the first letter
local function simpleRecipeFilter(resultName, searchText)
end

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

function DolgubonSetCrafter:RefreshRecipeList()
	self.recipeTree:Reset()

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


	-- local recipeLists = PROVISIONER_MANAGER:GetRecipeListData(craftingInteractionType)
	completeRecipeList = completeRecipeList or generateCompleteRecipeList()
	local recipeLists = completeRecipeList

	for _, listIndex in pairs(determinePartition()) do
		local recipeList = recipeLists[listIndex]
		-- If user does not know any of the recipes, then skip
		if recipeList then
			local parent
			for _, recipe in ipairs(recipeList.recipes) do
				if true then --- recipe.requiredCraftingStationType == craftingInteractionType and self.filterType == recipe.specialIngredientType then
					knowAnyRecipesInTab = true
					if  filterFunctionToUse(recipe.name, searchText) then --recipeFilter(recipe.resultItemId) then -- does recipe pass filter
						parent = parent or self.recipeTree:AddNode("ZO_ProvisionerNavigationHeader", {
							recipeListIndex = recipeList.recipeListIndex,
							name = recipeList.recipeListName,
							upIcon = recipeList.upIcon,
							downIcon = recipeList.downIcon,
							overIcon = recipeList.overIcon,
							})
						self.recipeTree:AddNode("ZO_ProvisionerNavigationEntry", recipe, parent)
						hasRecipesWithFilter = true
					end
				end
			end
		end
	end
	-- Keep the first node closed for easy scrolling
	local origSelectAnything = DolgubonSetCrafter.recipeTree.SelectAnything
	DolgubonSetCrafter.recipeTree.SelectAnything = function() end
	self.recipeTree:Commit()
	DolgubonSetCrafter.recipeTree.SelectAnything = origSelectAnything
	
	-- DolgubonSetCrafter.recipeTree.rootNode.children[1]:SetOpen(false)
	-- DolgubonSetCrafter.recipeTree.exclusive = false
	-- self.noRecipesLabel:SetHidden(hasRecipesWithFilter)
	if not hasRecipesWithFilter then
		if knowAnyRecipesInTab then
			-- self.noRecipesLabel:SetText(GetString(SI_PROVISIONER_NONE_MATCHING_FILTER))
		else
			--If there are no recipes all the types show the same message.
			-- self.noRecipesLabel:SetText(GetString(SI_PROVISIONER_NO_RECIPES))
			-- ZO_CheckButton_SetChecked(self.haveIngredientsCheckBox)
			-- ZO_CheckButton_SetChecked(self.haveSkillsCheckBox)
			-- ZO_CheckButton_SetUnchecked(self.isQuestItemCheckbox)
		end
		-- self:RefreshRecipeDetails()
	end

	-- ZO_CheckButton_SetEnableState(self.haveIngredientsCheckBox, knowAnyRecipesInTab)
	-- ZO_CheckButton_SetEnableState(self.haveSkillsCheckBox, knowAnyRecipesInTab)
	-- ZO_CheckButton_SetEnableState(self.isQuestItemCheckbox, knowAnyRecipesInTab)
end

DolgubonSetCrafter.initializeFunctions.InitializeFurnitureUI = DolgubonSetCrafter.InitializeRecipeTree
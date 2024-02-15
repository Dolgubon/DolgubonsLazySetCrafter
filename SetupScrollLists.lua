
local DolgubonScroll = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.scroll = DolgubonScroll

local MaterialScroll = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.MaterialScroll = MaterialScroll
DolgubonSetCrafter.materialList = DolgubonSetCrafter.materialList or {}

local FavouriteScroll = ZO_SortFilterList:Subclass()
DolgubonSetCrafter.FavouriteScroll = FavouriteScroll

local updateList = function() end
local updateMaterials = function() end


-- Create the scroll list for the queue
function DolgubonScroll:New(control)

	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		Reference = {},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "CraftingRequestTemplate", 30, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_AddDataType(self.list, 2, "FurnitureRequestTemplate", 30, function(control, data) self:SetupFurnitureEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "Reference"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "Reference", SorterKeys, self.currentSortOrder) end
	self.data = DolgubonSetCrafter.savedvars.queue
	return self
	
end

local validPriceSources

local function getLibPrice(itemLink)
	if LibPrice then 
		local price  = LibPrice.ItemLinkToPriceGold(itemLink)
		if price then
			return price
		end
	end
end

local function getMMPrice(itemLink)
	if MasterMerchant then
  		price = MasterMerchant:itemStats(itemLink, false).avgPrice
		if price then
			return price
		end 
	end
end
local function getATTPrice(itemLink)
	if  ArkadiusTradeTools and ArkadiusTradeTools.Modules
            and ArkadiusTradeTools.Modules.Sales and ArkadiusTradeTools.Modules.Sales.addMenuItems then
        local day_secs = 24*60*60
	    for _,day_ct in ipairs({ 10, 30 }) do
	        att = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(
	                        itemLink, GetTimeStamp() - (day_secs * day_ct))
	        if att and 0 < att then
	            return att
	       end
	    end
    end
end
local function getTTCPrice(itemLink)
	if TamrielTradeCentrePrice then
		local t = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if t and t.SuggestedPrice then
			return t.SuggestedPrice
		end
	end
end

local function addonChoicePrice(itemLink)
	for i = 2, #validPriceSources do
		if validPriceSources[i][2] then
			price = validPriceSources[i][3](itemLink)
			if price then
				return price
			end
		end
	end
end

local function generateValidPriceSources()
	local validPriceSources = 
	{
		{"Currently using Set Crafter's choice", true, addonChoicePrice},
		{"Currently using prices from LibPrice", LibPrice, getLibPrice},
		{'Currently using prices from MasterMerchant', MasterMerchant, getMMPrice},
		{'Currently using prices from Arkadius Trade Tools', ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales and ArkadiusTradeTools.Modules.Sales.addMenuItems, getATTPrice},
		{'Currently using prices from Tamriel Trade Center', TamrielTradeCentrePrice, getTTCPrice},
		{"Currently using the game's default prices", true, GetItemLinkValue},
	}
	for i = 2, #validPriceSources do
		if validPriceSources[i][2] then
			validPriceSources[1][1] = validPriceSources[i][1].." (Set Crafter's choice)"
			validPriceSources[1][4] = i
			return validPriceSources
		end
	end
end



function DolgubonSetCrafter.togglePriceSource()
	DolgubonSetCrafter.savedvars.currentPriceChoice = ((DolgubonSetCrafter.savedvars.currentPriceChoice ) % #validPriceSources )+ 1
	while not validPriceSources[DolgubonSetCrafter.savedvars.currentPriceChoice][2] and DolgubonSetCrafter.savedvars.currentPriceChoice~= validPriceSources[1][4] do
		DolgubonSetCrafter.savedvars.currentPriceChoice = ((DolgubonSetCrafter.savedvars.currentPriceChoice ) % #validPriceSources )+ 1
	end
	DolgubonSetCrafter.updateList()
end

local function getPrice(itemLink)
	local price
	if validPriceSources[DolgubonSetCrafter.savedvars.currentPriceChoice][2] then
		price = validPriceSources[DolgubonSetCrafter.savedvars.currentPriceChoice][3](itemLink)
		if price then
			return price
		end
	end
	return addonChoicePrice(itemLink) or 0
end

function DolgubonSetCrafter.getCurrentPriceAddonString()
	return validPriceSources[DolgubonSetCrafter.savedvars.currentPriceChoice][1]
end

local function round(price)
	price = math.floor( price * 100 + 0.5)
	price = price/100
	return price
end

local function updateCost()
	local cost = 0
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		local link = v["Name"]
		local price = round(getPrice(link))

		cost = cost + price * v["Amount"]
	end 
	cost = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(cost, NUMBER_ABBREVIATION_PRECISION_HUNDREDTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
	DolgubonSetCrafterWindowRightCost:SetText("Total Cost: "..cost.." |t20:20:esoui/art/currency/currency_gold_64.dds|t")
end

local function updateCurrentAmounts()
	DolgubonSetCrafter.recompileMatRequirements(DolgubonSetCrafter.materialList)

	for k, v in pairs(DolgubonSetCrafter.materialList) do
		local link = v["Name"]
		local bag, bank, craft = GetItemLinkStacks(link)
		v["Current"] =  bag + bank + craft
	end 
end

-- Create the scroll list for the materials
function MaterialScroll:New(control)
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		Amount = {},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "SetCrafterMaterialTemplate", 30, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "Amount"
	self.currentSortOrder = ZO_SORT_ORDER_DOWN
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "Amount", SorterKeys, self.currentSortOrder) end
	self.data = DolgubonSetCrafter.materialList

	local originalRefresh = self.RefreshData
	self.RefreshData = function(...)
		updateCurrentAmounts()
		originalRefresh(...)
		updateCost()
	end


	return self
	
end

function FavouriteScroll:New(control)
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "SetCrafterFavouriteTemplate", 30, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_DOWN
 	self.sortFunction = function(listEntry1, listEntry2) return 1 end
	self.data = DolgubonSetCrafter.savedvars.faves
	return self
	
end

function FavouriteScroll:SetupEntry(control, data)
	control.data = data
	control:setCurrent(data[1])
	control.label = control:GetNamedChild("Name")
	
	control.label:SetText(data[1].name)

	ZO_SortFilterList.SetupRow(self, control, data)
end

local function formatAmountEntry(self, amountRequired, current)
	local text
	if current < amountRequired	 then
		amountRequired = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(amountRequired, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		current = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		text = "|cFFBFBF"..tostring(current).."|r/"..tostring(amountRequired)
	else
		amountRequired = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(amountRequired, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		current = zo_strformat(SI_NUMBER_FORMAT, ZO_AbbreviateNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
		text = tostring(current).."/"..tostring(amountRequired)
	end
	self:SetText(text)
	local width = self:GetTextWidth()
	
end

function MaterialScroll:SetupEntry(control, data)

	control.data = data
	control.isKnown = data[1]["Amount"]<= data[1]["Current"]
	for k , v in pairs(data[1]) do
		control[k] = GetControl(control, k)
		if control[k] then
			if k == "Amount" then
				formatAmountEntry(control[k], v, data[1]["Current"])
			else
				control[k]:SetText(v)
			end
		end
	end
	local BG = GetControl(control, "BG")
	
	if BG then
		BG:SetAnchorFill(control)
		--BG.nonRecolorable = false
		--local colour = BG.SetColor
		--BG.SetColor = function() end
		--BG.HideSetColor = colour
		if not control.isKnown then
			--BG:SetColor(1,0.5,0.5,0.2)
			BG:SetCenterColor(1, 0.5, 0.5, 0.2)
			BG:SetEdgeColor(0,0,0,0)
			
		else
			--BG:SetColor(0.5,0.8,1,0.2)
			BG:SetEdgeColor(0,0,0, 0)
			BG:SetCenterColor(0.5,0.5,0.5,0.05)

		end
	end
	ZO_SortFilterList.SetupRow(self, control, data)
end

function DolgubonSetCrafter.outputSingleMatLine(control)
	local text
	text = tostring(control.data[1]["Amount"]).." "
	text = text..control.data[1]["Name"]
	return text
end

outputTexts = {}
--@nighn_9, 38



local function outputMultipleLinesChat(textToOutput)
	StartChatInput(textToOutput[1])
	local function OutputNextLine(eventCode,  channelType, fromName, text, isCustomerService, fromDisplayName)
	
		if fromDisplayName == GetDisplayName() or channelType == CHAT_CHANNEL_WHISPER_SENT then
			if text == textToOutput[1] then
				table.remove(textToOutput, 1)
				if #textToOutput>0 then
					StartChatInput(textToOutput[1])
				else
					d("Chat sending complete!")
					EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_CHAT_MESSAGE_CHANNEL)
				end
			else
			end
		end
	end
	EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_CHAT_MESSAGE_CHANNEL)
	EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name,EVENT_CHAT_MESSAGE_CHANNEL, OutputNextLine)
end

function DolgubonSetCrafter.outputAllMats()
	local tempMatHolder = {}
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		tempMatHolder[#tempMatHolder + 1] = v
	end
	if #tempMatHolder == 0 then return end
	table.sort(tempMatHolder, function(a, b) return a["Amount"]>b["Amount"]end)
	
	outputTexts  = {}
	local text = "Requires: "
	
	for i = 1, #tempMatHolder do
		
		if i %4 ==1 and i > 1 then
			
			outputTexts[#outputTexts + 1] = text
			text = "And: "
		end
		if i>1 and not (i %4 ==1 and i>1) then
			text = text.." l "
		end
		text =text.. tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"]
	end
	outputTexts[#outputTexts + 1] = text
	outputMultipleLinesChat(outputTexts)
end


function DolgubonSetCrafter.outputRequest()
	if next(DolgubonSetCrafter.materialList) == nil then 
		d("Dolgubon's Lazy Set Crafter: No items are in the queue! No mails sent")
		return 
	end
	local sets = {} -- A list of all items under the current set type.
	local setTypes = {} -- Used to keep the sets list in a certain order.
	local mailInfo = {}
	local outputTexts = {}
	local tempMatHolder = {}
	local text = ""
	local mailQueue = DolgubonSetCrafter.savedvars.queue

	for i, request in ipairs(mailQueue) do
		if request.typeId == 1 then
			local setName = request["Set"][2]
			if sets[setName] == nil then
				sets[setName] = {}
				table.insert(setTypes, setName) -- Save this index of this set's name
			end
			table.insert(sets[setName], DolgubonSetCrafter.convertRequestToText(request)) -- Store the readable crafting information
		end
	end
	for setName, requestInfos in pairs(sets) do
		outputTexts[#outputTexts + 1] = "From the set "..setName..", please make:"
		for i = 1, #requestInfos do
			if i %2 ==1 and i > 1 then
				outputTexts[#outputTexts + 1] = text
				text = ""
			else
				text = text.." "
			end
			text =text.. requestInfos[i]
		end
		outputTexts[#outputTexts + 1] = text
		text = ""
	end
	local addedProvisioningGreeting = false
	for i, request in pairs(mailQueue) do
		if request.typeId == 2 then
			if not addedProvisioningGreeting then
				addedProvisioningGreeting = true
				outputTexts[#outputTexts + 1] = "Please create these provisioning/furniture items:"
			end
			outputTexts[#outputTexts + 1] = request.Quantity[1].."x "..request.Link
		end
	end
	outputMultipleLinesChat(outputTexts)
end



local function removeFauxRequest(reference)
	for i = 1, #DolgubonSetCrafter.savedvars.queue do 

		if DolgubonSetCrafter.savedvars.queue[i]["reference"]==reference then
			table.remove( DolgubonSetCrafter.savedvars.queue, i)
			return
		end
	end
end

function DolgubonScroll:SetupEntry(control, data)
	control.A_ScrollList = self
	control.data = data
	if data[1].CraftRequestTable[7] ~= CRAFTING_TYPE_JEWELRYCRAFTING then
		control.usesMimicStone = data[1].CraftRequestTable[6]
		GetControl(control, "MimicStone"):SetHidden(not data[1].CraftRequestTable[6])
		control:GetNamedChild("Style"):SetHidden(false)
	else
		control:GetNamedChild("Style"):SetHidden(true)
		GetControl(control, "MimicStone"):SetHidden(true)
		control.usesMimicStone = false
	end
	control.qualityString = zo_strformat(DolgubonSetCrafter.localizedStrings.UIStrings.qualityString, data[1].Quality[2])
	for k , v in pairs (data[1]) do
		control[k] = GetControl(control, k)
		if control[k] then
			if type(v)=="table" then
				control[k]:SetText(v[2])
				control[k]:SetColor(1,1,0)

				
				if k == "Enchant" then
					control[k]:ApplyEnchantColour()
				else
					control[k]:ApplyColour(v.isKnown)
				end
			else
				if k == "Enchant" then
					control[k]:SetText(v)
					control[k]:ApplyEnchantColour()
				else
					control[k]:SetText(v)
				end
			end
		end
	end

	local button = control:GetNamedChild( "RemoveButton")
	if DolgubonSetCrafter.isRequestInProgressByReference(data[1].Reference) then

		button.tooltip = DolgubonSetCrafter.localizedStrings.UIStrings.inProgressCrafting
		WINDOW_MANAGER:ApplyTemplateToControl(button, "SetCrafterRequestInProgress")
	else
		WINDOW_MANAGER:ApplyTemplateToControl(button, "SetCrafterRequestNotInProgress")
		
		button.tooltip = nil
	end

	function button:onClickety ()   DolgubonSetCrafter.removeFromScroll(data[1].Reference, true)  end
	--function control:onClicked () DolgubonsGuildBlacklistWindowInputBox:SetText(data.name) end
	
	ZO_SortFilterList.SetupRow(self, control, data)
	
end

function DolgubonScroll:SetupFurnitureEntry(control, data)

	control.data = data
	-- control.qualityString = zo_strformat(DolgubonSetCrafter.localizedStrings.UIStrings.qualityString, data[1].Quality[2])
	local qual = data[1]["Quality"][1]
	local qualityColour = {GetItemQualityColor(qual or 2)}
	for k , v in pairs (data[1]) do

		control[k] = GetControl(control, k)

		if control[k] then
			if type(v)=="table" then
				control[k]:SetText(v[2])
				control[k]:SetHidden(false)
				control[k]:SetColor(unpack(qualityColour))
				control[k]:ApplyColour(true)
			end
		end
	end

	local button = control:GetNamedChild( "RemoveButton")
	WINDOW_MANAGER:ApplyTemplateToControl(button, "SetCrafterRequestNotInProgress")
	
	button.tooltip = nil

	function button:onClickety ()   DolgubonSetCrafter.removeFromScroll(data[1].Reference, true)  end
	--function control:onClicked () DolgubonsGuildBlacklistWindowInputBox:SetText(data.name) end
	
	ZO_SortFilterList.SetupRow(self, control, data)
	
end


function DolgubonScroll:BuildMasterList()
	self.masterList = {}

	for k, v in pairs(self.data) do 

		table.insert(self.masterList, {
			v, ["typeId"] = v.typeId
		})

	end

end

function DolgubonScroll:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end


function DolgubonScroll:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(data.typeId or 1, data))
	end
end

MaterialScroll.BuildMasterList = DolgubonScroll.BuildMasterList
MaterialScroll.SortScrollList = DolgubonScroll.SortScrollList
MaterialScroll.FilterScrollList = DolgubonScroll.FilterScrollList

FavouriteScroll.BuildMasterList = DolgubonScroll.BuildMasterList
FavouriteScroll.FilterScrollList = DolgubonScroll.FilterScrollList

function DolgubonSetCrafter.setupScrollLists()
	DolgubonSetCrafter.manager = DolgubonScroll:New(CraftingQueueScroll)
	
	DolgubonSetCrafter.materialManager = MaterialScroll:New(DolgubonSetCrafterWindowMaterialList)
	DolgubonSetCrafter.favouritesManager = FavouriteScroll:New(DolgubonSetCrafterWindowFavouritesScroll)
	validPriceSources = generateValidPriceSources()
end

local function countTotalItems()
	local sum = 0
	for k, v in pairs(DolgubonSetCrafter.savedvars.queue) do
		sum = sum + tonumber((v.Quantity and v.Quantity[1]) or 1)
	end
	return sum
end

DolgubonSetCrafter.countTotalQueuedItems = countTotalItems

updateList = function ()
	DolgubonSetCrafter.manager:RefreshData()
	DolgubonSetCrafter.materialManager:RefreshData()
	DolgubonSetCrafter.favouritesManager:RefreshData()
	if #DolgubonSetCrafter.savedvars.queue == 0 then 
		CraftingQueueScrollCounter:SetText()
	else
		CraftingQueueScrollCounter:SetText(" - "..countTotalItems())
	end
 end
DolgubonSetCrafter.updateList = updateList


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
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "Reference"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data[1], listEntry2.data[1], "Reference", SorterKeys, self.currentSortOrder) end
	self.data = DolgubonSetCrafter.savedvars.queue
	return self
	
end
--TamrielTradeCentrePrice:GetPriceInfo

local function getPrice(itemLink)
	
	if LibPrice then 
		local price  = LibPrice.ItemLinkToPriceGold(itemLink)
		if price then
			return price
		end
	end
	if MasterMerchant then
		local itemID = tonumber(string.match(itemLink, '|H.-:item:(.-):'))
		local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
		local price = MasterMerchant:toolTipStats(itemID, itemIndex, true, nil, false)['avgPrice']
		if price then
			return price
		end 
	end
	if TamrielTradeCentrePrice then
		local t = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if t and t.SuggestedPrice then
			return t.SuggestedPrice
		end
	end
	local default =GetItemLinkValue(itemLink)
	return default
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
	DolgubonSetCrafterWindowRightCost:SetText("Total Cost: "..cost.." |t20:20:esoui/art/currency/currency_gold_64.dds|t")
end
local function updateCurrentAmounts()
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
	local originalRefresh = self.RefreshData
	self.RefreshData = function(...)
		-- updateCurrentAmounts()
		originalRefresh(...)
		-- updateCost()
	end
	--d("Setting up 1")
	return self
	
end

function FavouriteScroll:SetupEntry(control, data)
	--d("Setting up")
	control.data = data
	control:setCurrent(data[1])
	control.label = control:GetNamedChild("Name")
	
	control.label:SetText("Hello")
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
			testActualOutput = text
			testAssume = textToOutput[1]
			if text == textToOutput[1] then
				table.remove(textToOutput, 1)
				if #textToOutput>0 then
					StartChatInput(textToOutput[1])
				else
					EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_CHAT_MESSAGE_CHANNEL)
				end
			else
			end
		end
	end
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



local function removeFauxRequest(reference)
	for i = 1, #DolgubonSetCrafter.savedvars.queue do 

		if DolgubonSetCrafter.savedvars.queue[i]["reference"]==reference then
			table.remove( DolgubonSetCrafter.savedvars.queue, i)
			return
		end
	end
end

function DolgubonScroll:SetupEntry(control, data)

	control.data = data
	if data[1].CraftRequestTable[7] ~= CRAFTING_TYPE_JEWELRYCRAFTING then
		control.usesMimicStone = data[1].CraftRequestTable[6]
		GetControl(control, "MimicStone"):SetHidden(not data[1].CraftRequestTable[6])
	else
		control:GetNamedChild("Style"):SetHidden(true)
		GetControl(control, "MimicStone"):SetHidden(true)
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
					control[k]:ApplyColour(v[3])
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

	button = control:GetNamedChild( "RemoveButton")

	function button:onClickety ()   DolgubonSetCrafter.removeFromScroll(data[1].Reference)  end
	--function control:onClicked () DolgubonsGuildBlacklistWindowInputBox:SetText(data.name) end
	
	ZO_SortFilterList.SetupRow(self, control, data)
	
end


function DolgubonScroll:BuildMasterList()
	self.masterList = {}

	for k, v in pairs(self.data) do 

		table.insert(self.masterList, {
			v
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
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

MaterialScroll.BuildMasterList = DolgubonScroll.BuildMasterList
MaterialScroll.SortScrollList = DolgubonScroll.SortScrollList
MaterialScroll.FilterScrollList = DolgubonScroll.FilterScrollList

FavouriteScroll.BuildMasterList = DolgubonScroll.BuildMasterList
FavouriteScroll.FilterScrollList = DolgubonScroll.FilterScrollList

function DolgubonSetCrafter.setupScrollLists()
	DolgubonSetCrafter.manager = DolgubonScroll:New(CraftingQueueScroll) -- check
	
	DolgubonSetCrafter.materialManager = MaterialScroll:New(DolgubonSetCrafterWindowMaterialList)
	DolgubonSetCrafter.favouritesManager = FavouriteScroll:New(DolgubonSetCrafterWindowFavouritesScroll)
end

updateList = function () 
	DolgubonSetCrafter.manager:RefreshData()
	DolgubonSetCrafter.materialManager:RefreshData()
	DolgubonSetCrafter.favouritesManager:RefreshData()
	if #DolgubonSetCrafter.savedvars.queue == 0 then 
		CraftingQueueScrollCounter:SetText()
	else
		CraftingQueueScrollCounter:SetText(" - "..#DolgubonSetCrafter.savedvars.queue)
	end
 end
DolgubonSetCrafter.updateList = updateList

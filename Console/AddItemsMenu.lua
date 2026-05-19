DolgubonSetCrafter.initializeFunctions = DolgubonSetCrafter.initializeFunctions or {}

local panel =  
{
     type = "panel",
     name = "DSC: Add Items",
     registerForRefresh = true,
     displayName = "|c8080FFDSC: Add Items|r",
     author = "@Dolgubon"
}
local function shallowCopy (source, destination)
	for k, v in pairs(source) do
		destination[k] = v
	end
end
local gearTypeTable=
{
	weapon={},
	armour={},
	jewelry={},
}
DolgubonSetCrafter.selections = 
{
	patterns={},
	weight={},
	level={},
	isCP={},
	enchantment = ZO_ShallowTableCopy(gearTypeTable,{}),
	trait = ZO_ShallowTableCopy(gearTypeTable,{}),
	style={},
	quality={},
	enchantQuality={},
}

local SettingsStrings = DolgubonSetCrafter.localizedStrings.SettingsStrings

local options =
{
	{
		type = "divider",
		height = 15,
		alpha = 0.5,
		width = "full"
	},
		{
		type = "button",
		name = "Add to queue",
		tooltip ="Add item to queue with the following selections",
		setFunc = function(value)
			d("Adding to queue")
		end,
	},
	{
		type = "checkbox",
		name = "Head",
		tooltip ="Add a head piece",
		getFunc = function() return DolgubonSetCrafter.selections.Head end,
		setFunc = function(value) 
			DolgubonSetCrafter.selections.Head=value
		end,
	},
		{
		type = "checkbox",
		name = "Shoulder",
		tooltip ="Add a shoulder piece",
		getFunc = function() return DolgubonSetCrafter.selections.Shoulder end,
		setFunc = function(value) 
			DolgubonSetCrafter.selections.Shoulder=value
		end,
	},
	{
		type = "checkbox",
		name = "Waist",
		tooltip ="Add a waist piece",
		getFunc = function() return DolgubonSetCrafter.selections.Waist end,
		setFunc = function(value) 
			DolgubonSetCrafter.selections.Waist=value
		end,
	},
	{
		type = "dropdown",
		name =  "Piece",
		tooltip = "Which piece to add",
		choices = {"Head","Shoulders","Waist"},
		choicesValues = {"Head","Shoulder","Waist"},
		getFunc = function()
			return "Head" end,
		setFunc = function(value) 
			WritCreater:GetSettings().rewardHandling[rewardName][craftingIndex] = value
		end,
	},
}

function DolgubonSetCrafter.initializeFunctions.initializeAddItemsMenu()

	local LAM = LibAddonMenu2 or LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsSetCrafter", panel)
	
	LAM:RegisterOptionControls("DolgubonsSetCrafter", options)
end
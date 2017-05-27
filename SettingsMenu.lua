local panel =  
{
     type = "panel",
     name = "Dolgubon's Lazy Set Crafter",
     registerForRefresh = true,
     displayName = "|c8080FF Dolgubon's Lazy Set Crafter|r",
     author = "@Dolgubon"
}
test = true
local options =
{
	{
		type = "checkbox",
		name = "ShowAtStation",
		tooltip ="Always show the Set Crafter UI at crafting stations",
		getFunc = function() return test end,
		setFunc = function(value) 
			test = value
		end,
	},
}

function DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu()

	local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsSetCrafter", panel)
	
	LAM:RegisterOptionControls("DolgubonsSetCrafter", options)
end